//The method to bring the changes form the other branches to the main branch
// # Switch to main branch
// git checkout main

// # Pull latest changes from remote
// git pull origin main

// # Merge dev branch into main
// git merge dev

// # Push to remote
// git push origin main

// name: Build and Release APK

// on:
//   push:
//     branches:
//       - main  
//   workflow_dispatch: 

// env:
//   APK_NAME: "Wallify"
//   APP_VERSION: "1.1.8"
//   BUILD_NUMBER: ${{ github.run_number }}
//   CHANGES: |
//     - Minor bug fixes
//     - Automated build #${{ github.run_number }}

// jobs:
//   build:
//     name: Build APK
//     runs-on: ubuntu-latest

//     steps:
//       - name: Checkout repository
//         uses: actions/checkout@v3

//       - name: Set up Java
//         uses: actions/setup-java@v3
//         with:
//           java-version: '17' 
//           distribution: temurin

//       - name: Set up Flutter
//         uses: subosito/flutter-action@v2
//         with:
//           channel: 'stable'
//           flutter-version: '3.16.0'  # Specify version for consistency

//       - name: Flutter doctor
//         run: flutter doctor -v

//       - name: Install dependencies
//         run: flutter pub get

//       - name: Run tests
//         run: flutter test

//       - name: Decode Keystore
//         run: |
//           echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/my-release-key.jks

//       - name: Create key.properties
//         run: |
//           cat << EOF > android/key.properties
//           storePassword=${{ secrets.KEYSTORE_PASSWORD }}
//           keyPassword=${{ secrets.KEY_PASSWORD }}
//           keyAlias=${{ secrets.KEY_ALIAS }}
//           storeFile=my-release-key.jks
//           EOF

//       - name: Verify keystore setup
//         run: |
//           ls -la android/app/my-release-key.jks
//           cat android/key.properties

//       - name: Build Release APK
//         run: flutter build apk --release --build-name=${{ env.APP_VERSION }} --build-number=${{ env.BUILD_NUMBER }}
      
//       - name: Rename APK with Custom Name
//         run: |
//           mv build/app/outputs/flutter-apk/app-release.apk \
//              build/app/outputs/flutter-apk/${{ env.APK_NAME }}-v${{ env.APP_VERSION }}-${{ env.BUILD_NUMBER }}.apk

//       - name: Upload APK
//         uses: actions/upload-artifact@v4
//         with:
//           name: release-apk
//           path: build/app/outputs/flutter-apk/${{ env.APK_NAME }}-v${{ env.APP_VERSION }}-${{ env.BUILD_NUMBER }}.apk
//           retention-days: 7
  
//   release:
//     name: Release APK
//     needs: build
//     runs-on: ubuntu-latest
//     if: github.ref == 'refs/heads/main'  # Only release from main branch

//     steps:
//       - name: Download APK artifact
//         uses: actions/download-artifact@v4
//         with:
//           name: release-apk
//           path: ./

//       - name: List downloaded files
//         run: ls -la

//       - name: Create GitHub Release
//         uses: ncipollo/release-action@v1
//         with:
//           artifacts: "${{ env.APK_NAME }}-v${{ env.APP_VERSION }}-${{ env.BUILD_NUMBER }}.apk"
//           token: ${{ secrets.GITHUB_TOKEN }}
//           tag: "v${{ env.APP_VERSION }}"
//           name: "Wallify v${{ env.APP_VERSION }}"
//           body: |
//             ${{ env.CHANGES }}
            
//             **Build Details:**
//             - Build Number: ${{ env.BUILD_NUMBER }}
//             - Commit: ${{ github.sha }}
//             - Triggered by: ${{ github.actor }}
//           draft: false
//           prerelease: false
//           skipIfReleaseExists: true
