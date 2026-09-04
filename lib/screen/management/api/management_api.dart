import 'package:flutter/foundation.dart';
import 'package:omspos/screen/management/model/management_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagementApi {
  static SupabaseClient get _client => Supabase.instance.client;
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void _notifyChanged() => changes.value++;

  static String get currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('You must sign in first.');
    return id;
  }

  static Future<void> registerOwner({
    required String businessName,
    String? phone,
    String? address,
  }) async {
    final userId = currentUserId;
    final role = await getCurrentUserRole();
    if (role != 'landlord' && role != 'admin') {
      throw StateError('This account is registered as a renter.');
    }
    if (phone != null && phone.trim().isNotEmpty) {
      await _client
          .from('users')
          .update({'phone': phone.trim()}).eq('user_id', userId);
    }
    await _client.from('owner_profiles').upsert({
      'user_id': userId,
      'business_name': businessName.trim(),
      'business_address': address?.trim(),
      'onboarding_complete': true,
    });
    _notifyChanged();
  }

  static Future<String> getCurrentUserRole() async {
    final result = await _client
        .from('users')
        .select('user_type')
        .eq('user_id', currentUserId)
        .single();
    return result['user_type']?.toString() ?? 'tenant';
  }

  static Future<Map<String, dynamic>?> getOwnerProfile() async {
    return await _client
        .from('owner_profiles')
        .select()
        .eq('user_id', currentUserId)
        .maybeSingle();
  }

  static Future<List<Map<String, dynamic>>> getAreas() async {
    final result =
        await _client.from('area').select('area_id,name').order('name');
    return List<Map<String, dynamic>>.from(result);
  }

  static Future<List<OwnerProperty>> getProperties() async {
    final result = await _client
        .from('owner_property_summary')
        .select()
        .eq('landlord_id', currentUserId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result)
        .map(OwnerProperty.fromJson)
        .toList();
  }

  static Future<String> saveProperty({
    String? propertyId,
    required Map<String, dynamic> values,
    List<String> images = const [],
  }) async {
    final payload = {...values, 'landlord_id': currentUserId};
    late String id;
    if (propertyId == null) {
      final row =
          await _client.from('properties').insert(payload).select().single();
      id = row['property_id'].toString();
    } else {
      await _client
          .from('properties')
          .update(payload)
          .eq('property_id', propertyId);
      id = propertyId;
    }
    if (images.isNotEmpty) {
      await _client.from('images').delete().eq('property_id', id);
      await _client.from('images').insert(
        {'property_id': id, 'image_url': images},
      );
    }
    _notifyChanged();
    return id;
  }

  static Future<Map<String, dynamic>> getProperty(String id) async {
    return await _client
        .from('property_with_images')
        .select()
        .eq('property_id', id)
        .single();
  }

  static Future<List<String>> getRoomImages(String roomId) async {
    final row = await _client
        .from('room_with_images')
        .select('images')
        .eq('room_id', roomId)
        .single();
    return List<String>.from(row['images'] as List? ?? const []);
  }

  static Future<void> replacePropertyImages(
      String propertyId, List<String> urls) async {
    await _client.from('images').delete().eq('property_id', propertyId);
    if (urls.isNotEmpty) {
      await _client.from('images').insert({
        'property_id': propertyId,
        'image_url': urls,
      });
    }
    _notifyChanged();
  }

  static Future<void> replaceRoomImages(
      String roomId, List<String> urls) async {
    await _client.from('room_images').delete().eq('room_id', roomId);
    if (urls.isNotEmpty) {
      await _client.from('room_images').insert({
        'room_id': roomId,
        'image_url': urls,
      });
    }
    _notifyChanged();
  }

  static Future<List<ManagedUnit>> getUnits(String propertyId) async {
    final result = await _client
        .from('owner_unit_details')
        .select()
        .eq('property_id', propertyId)
        .order('room_number');
    return List<Map<String, dynamic>>.from(result)
        .map(ManagedUnit.fromJson)
        .toList();
  }

  static Future<String> saveUnit({
    String? roomId,
    required Map<String, dynamic> values,
    List<String> images = const [],
  }) async {
    late String id;
    if (roomId == null) {
      final row = await _client.from('rooms').insert(values).select().single();
      id = row['room_id'].toString();
    } else {
      await _client.from('rooms').update(values).eq('room_id', roomId);
      id = roomId;
    }
    if (images.isNotEmpty) {
      await _client.from('room_images').delete().eq('room_id', id);
      await _client.from('room_images').insert(
        {'room_id': id, 'image_url': images},
      );
    }
    _notifyChanged();
    return id;
  }

  static Future<void> assignTenant({
    required String propertyId,
    required String roomId,
    required Map<String, dynamic> values,
  }) async {
    await _client.rpc('assign_tenant', params: {
      'p_property_id': propertyId,
      'p_room_id': roomId,
      'p_tenant_name': values['tenant_name'],
      'p_tenant_phone': values['tenant_phone'],
      'p_tenant_email': values['tenant_email'],
      'p_emergency_contact': values['emergency_contact'],
      'p_lease_start': values['lease_start'],
      'p_lease_end': values['lease_end'],
      'p_monthly_rent': values['monthly_rent'],
      'p_security_deposit': values['security_deposit'],
      'p_rent_due_day': values['rent_due_day'],
      'p_notes': values['notes'],
    });
    _notifyChanged();
  }

  static Future<void> vacateTenant(String tenancyId) async {
    await _client.rpc('vacate_tenant', params: {'p_tenancy_id': tenancyId});
    _notifyChanged();
  }

  static Future<OwnerMetrics> getMetrics() async {
    final result = await _client
        .from('owner_dashboard_summary')
        .select()
        .eq('owner_id', currentUserId)
        .maybeSingle();
    return OwnerMetrics.fromJson(result);
  }

  static Future<List<RentLedgerItem>> getRentLedger() async {
    final result = await _client
        .from('owner_rent_ledger')
        .select()
        .eq('owner_id', currentUserId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(result)
        .map(RentLedgerItem.fromJson)
        .toList();
  }

  static Future<List<RentLedgerItem>> getTenancyLedger(String tenancyId) async {
    final result = await _client
        .from('owner_rent_ledger')
        .select()
        .eq('tenancy_id', tenancyId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(result)
        .map(RentLedgerItem.fromJson)
        .toList();
  }

  static Future<void> markRentPaid(String paymentId, double amount) async {
    await _client.rpc('record_rent_payment', params: {
      'p_rent_payment_id': paymentId,
      'p_amount': amount,
      'p_method': 'cash',
      'p_notes': null,
    });
    _notifyChanged();
  }

  static Future<void> addExpense({
    required String propertyId,
    String? roomId,
    required String category,
    required String description,
    required double amount,
    required DateTime expenseDate,
  }) async {
    await _client.from('property_expenses').insert({
      'owner_id': currentUserId,
      'property_id': propertyId,
      'room_id': roomId,
      'category': category,
      'description': description,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T').first,
    });
    _notifyChanged();
  }

  static Future<List<Map<String, dynamic>>> getMaintenance(
      String propertyId) async {
    final result = await _client
        .from('maintenance_requests')
        .select('*,rooms(room_number)')
        .eq('property_id', propertyId)
        .order('reported_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  static Future<void> addMaintenance({
    required String propertyId,
    String? roomId,
    required String title,
    required String description,
    required String priority,
  }) async {
    await _client.from('maintenance_requests').insert({
      'owner_id': currentUserId,
      'property_id': propertyId,
      'room_id': roomId,
      'title': title,
      'description': description,
      'priority': priority,
    });
    _notifyChanged();
  }

  static Future<void> resolveMaintenance(String id) async {
    await _client.from('maintenance_requests').update({
      'status': 'resolved',
      'resolved_at': DateTime.now().toIso8601String(),
    }).eq('maintenance_id', id);
    _notifyChanged();
  }
}
