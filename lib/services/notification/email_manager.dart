// https://xuq.supabase.co/functions/v1/order-email
// Content-Type  application/json
// Authorization Anon key of supabae eg ("Bearer eyvdfdfhfgh...................")
// apikey Anon key of supabase eg("eydgdfgdfg.............")

// {
//   "email": "thakuriumesh919@gmail.com",
//   "email_type": "BOOKING_CONFIRMED",
//   "booking_data": {
//     "customer_name": "Thakuri Umesh",
//     "booking_id": "BK-2025-001684",
//     "room_type": "KING SUITE",
//     "checkin_date": "2024-01-15",
//     "checkout_date": "2024-01-20",
//     "number_of_guests": 2,
//     "total_amount": "$450.00",
//     "property_name": "Solti Hotel",
//     "property_address": "Kalimati,Kathmandu",
//     "property_phone": "+977-9868732774"
//   }
// }

// Complete Step-by-Step Process:

// 1. Generate the keystore:

// # Navigate to your project directory
// cd your_flutter_project

// # Generate keystore
// keytool -genkey -v \
//   -keystore android/app/upload-keystore.jks \
//   -keyalg RSA \
//   -keysize 2048 \
//   -validity 10000 \
//   -alias upload \
//   -storetype JKS


//   2. Verify the keystore was created:

// keytool -list -v -keystore android/app/upload-keystore.jks -alias upload

//   3. Create key.properties file:

// storePassword=your_keystore_password
// keyPassword=your_key_password
// keyAlias=upload
// storeFile=upload-keystore.jks


//   4. Update android/app/build.gradle:

// def keystoreProperties = new Properties()
// def keystorePropertiesFile = rootProject.file('key.properties')
// if (keystorePropertiesFile.exists()) {
//     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
// }

// android {
//     // ... existing code

//     signingConfigs {
//         release {
//             keyAlias keystoreProperties['keyAlias']
//             keyPassword keystoreProperties['keyPassword']
//             storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
//             storePassword keystoreProperties['storePassword']
//         }
//     }

//     buildTypes {
//         release {
//             signingConfig signingConfigs.release
//             // ... other release config
//         }
//     }
// }
