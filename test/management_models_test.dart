import 'package:flutter_test/flutter_test.dart';
import 'package:omspos/screen/management/model/management_models.dart';

void main() {
  test('owner metrics calculate occupancy and net income', () {
    final metrics = OwnerMetrics.fromJson({
      'property_count': 2,
      'unit_count': 10,
      'occupied_count': 8,
      'monthly_potential': 100000,
      'collected_this_month': 70000,
      'expenses_this_month': 12000,
    });

    expect(metrics.occupancyRate, .8);
    expect(metrics.netIncome, 58000);
  });

  test('managed unit tolerates an empty tenancy', () {
    final unit = ManagedUnit.fromJson({
      'room_id': 'room-1',
      'property_id': 'property-1',
      'room_number': 'A-1',
      'rent_amount': 15000,
      'security_deposit': 15000,
      'is_occupied': false,
    });

    expect(unit.kind, 'room');
    expect(unit.rentDueDay, 1);
    expect(unit.tenantName, isNull);
    expect(unit.balanceDue, 0);
  });

  test('rent ledger calculates remaining balance', () {
    final payment = RentLedgerItem.fromJson({
      'rent_payment_id': 'payment-1',
      'tenant_name': 'Asha',
      'room_number': '2B',
      'due_date': '2026-09-05',
      'amount': 20000,
      'paid_amount': 7500,
      'status': 'partial',
    });

    expect(payment.balance, 12500);
    expect(payment.status, 'partial');
  });
}
