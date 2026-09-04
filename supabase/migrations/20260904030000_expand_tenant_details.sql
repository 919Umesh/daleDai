DROP VIEW IF EXISTS public.owner_unit_details;
CREATE VIEW public.owner_unit_details WITH (security_invoker = true) AS
SELECT r.*, t.tenancy_id, t.tenant_name, t.tenant_phone, t.tenant_email,
  t.emergency_contact, t.lease_start, t.lease_end, t.notes AS tenancy_notes,
  t.rent_due_day AS tenancy_rent_due_day,
  next_payment.due_date AS next_due_date,
  COALESCE(next_payment.amount - next_payment.paid_amount, 0)::numeric AS balance_due
FROM rooms r
LEFT JOIN LATERAL (
  SELECT * FROM tenancies x
  WHERE x.room_id = r.room_id AND x.status IN ('active','notice') LIMIT 1
) t ON true
LEFT JOIN LATERAL (
  SELECT rp.* FROM rent_payments rp
  WHERE rp.tenancy_id = t.tenancy_id AND rp.status IN ('upcoming','due','partial')
  ORDER BY rp.due_date LIMIT 1
) next_payment ON true;

GRANT SELECT ON public.owner_unit_details TO authenticated;
