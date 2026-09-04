class OwnerProperty {
  const OwnerProperty({
    required this.id,
    required this.title,
    required this.address,
    required this.city,
    required this.type,
    required this.isActive,
    required this.unitCount,
    required this.occupiedCount,
    required this.monthlyPotential,
  });

  final String id;
  final String title;
  final String address;
  final String city;
  final String type;
  final bool isActive;
  final int unitCount;
  final int occupiedCount;
  final double monthlyPotential;

  int get vacantCount => unitCount - occupiedCount;

  factory OwnerProperty.fromJson(Map<String, dynamic> json) => OwnerProperty(
        id: json['property_id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled property',
        address: json['address']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        type: json['property_type']?.toString() ?? 'property',
        isActive: json['is_active'] as bool? ?? true,
        unitCount: (json['unit_count'] as num?)?.toInt() ?? 0,
        occupiedCount: (json['occupied_count'] as num?)?.toInt() ?? 0,
        monthlyPotential: (json['monthly_potential'] as num?)?.toDouble() ?? 0,
      );
}

class ManagedUnit {
  const ManagedUnit({
    required this.id,
    required this.propertyId,
    required this.number,
    required this.kind,
    required this.type,
    required this.rent,
    required this.deposit,
    required this.isOccupied,
    required this.description,
    required this.rentDueDay,
    required this.tenantName,
    required this.tenantPhone,
    required this.tenantEmail,
    required this.emergencyContact,
    required this.leaseStart,
    required this.leaseEnd,
    required this.tenancyNotes,
    required this.tenancyId,
    required this.nextDueDate,
    required this.balanceDue,
  });

  final String id;
  final String propertyId;
  final String number;
  final String kind;
  final String type;
  final double rent;
  final double deposit;
  final bool isOccupied;
  final String description;
  final int rentDueDay;
  final String? tenantName;
  final String? tenantPhone;
  final String? tenantEmail;
  final String? emergencyContact;
  final DateTime? leaseStart;
  final DateTime? leaseEnd;
  final String? tenancyNotes;
  final String? tenancyId;
  final DateTime? nextDueDate;
  final double balanceDue;

  factory ManagedUnit.fromJson(Map<String, dynamic> json) => ManagedUnit(
        id: json['room_id']?.toString() ?? '',
        propertyId: json['property_id']?.toString() ?? '',
        number: json['room_number']?.toString() ?? 'Unit',
        kind: json['unit_kind']?.toString() ?? 'room',
        type: json['room_type']?.toString() ?? 'single',
        rent: (json['rent_amount'] as num?)?.toDouble() ?? 0,
        deposit: (json['security_deposit'] as num?)?.toDouble() ?? 0,
        isOccupied: json['is_occupied'] as bool? ?? false,
        description: json['description']?.toString() ?? '',
        rentDueDay: (json['rent_due_day'] as num?)?.toInt() ?? 1,
        tenantName: json['tenant_name']?.toString(),
        tenantPhone: json['tenant_phone']?.toString(),
        tenantEmail: json['tenant_email']?.toString(),
        emergencyContact: json['emergency_contact']?.toString(),
        leaseStart: DateTime.tryParse(json['lease_start']?.toString() ?? ''),
        leaseEnd: DateTime.tryParse(json['lease_end']?.toString() ?? ''),
        tenancyNotes: json['tenancy_notes']?.toString(),
        tenancyId: json['tenancy_id']?.toString(),
        nextDueDate: DateTime.tryParse(json['next_due_date']?.toString() ?? ''),
        balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      );
}

class OwnerMetrics {
  const OwnerMetrics({
    this.properties = 0,
    this.units = 0,
    this.occupied = 0,
    this.monthlyPotential = 0,
    this.collectedThisMonth = 0,
    this.outstanding = 0,
    this.expensesThisMonth = 0,
    this.openMaintenance = 0,
  });

  final int properties;
  final int units;
  final int occupied;
  final double monthlyPotential;
  final double collectedThisMonth;
  final double outstanding;
  final double expensesThisMonth;
  final int openMaintenance;

  double get occupancyRate => units == 0 ? 0 : occupied / units;
  double get netIncome => collectedThisMonth - expensesThisMonth;

  factory OwnerMetrics.fromJson(Map<String, dynamic>? json) => OwnerMetrics(
        properties: (json?['property_count'] as num?)?.toInt() ?? 0,
        units: (json?['unit_count'] as num?)?.toInt() ?? 0,
        occupied: (json?['occupied_count'] as num?)?.toInt() ?? 0,
        monthlyPotential: (json?['monthly_potential'] as num?)?.toDouble() ?? 0,
        collectedThisMonth:
            (json?['collected_this_month'] as num?)?.toDouble() ?? 0,
        outstanding: (json?['outstanding'] as num?)?.toDouble() ?? 0,
        expensesThisMonth:
            (json?['expenses_this_month'] as num?)?.toDouble() ?? 0,
        openMaintenance: (json?['open_maintenance'] as num?)?.toInt() ?? 0,
      );
}

class RentLedgerItem {
  const RentLedgerItem({
    required this.id,
    required this.tenantName,
    required this.unitNumber,
    required this.dueDate,
    required this.amount,
    required this.paidAmount,
    required this.status,
  });

  final String id;
  final String tenantName;
  final String unitNumber;
  final DateTime dueDate;
  final double amount;
  final double paidAmount;
  final String status;

  double get balance => amount - paidAmount;

  factory RentLedgerItem.fromJson(Map<String, dynamic> json) => RentLedgerItem(
        id: json['rent_payment_id']?.toString() ?? '',
        tenantName: json['tenant_name']?.toString() ?? 'Tenant',
        unitNumber: json['room_number']?.toString() ?? 'Unit',
        dueDate: DateTime.tryParse(json['due_date']?.toString() ?? '') ??
            DateTime.now(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
        status: json['status']?.toString() ?? 'due',
      );
}
