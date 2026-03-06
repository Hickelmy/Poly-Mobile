# Configuração Firebase para Polys Mobile

## 1. Criar projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto ou use o mesmo do frontend
3. Ative o **Authentication** > **Sign-in method** > **Google**

## 2. Configurar Android

1. No Firebase Console, adicione um app Android
2. Package name: `com.polys.mobile` (verifique em `android/app/build.gradle`)
3. Baixe o `google-services.json`
4. Coloque em: `android/app/google-services.json`
5. Em `android/build.gradle`, adicione:
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
     }
   }
   ```
6. Em `android/app/build.gradle`, adicione no final:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## 3. Configurar iOS

1. No Firebase Console, adicione um app iOS
2. Bundle ID: verifique em `ios/Runner.xcodeproj`
3. Baixe o `GoogleService-Info.plist`
4. Coloque em: `ios/Runner/GoogleService-Info.plist`
5. Adicione ao `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.SEU-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

## 4. Variáveis de ambiente (Backend)

Certifique-se de que o `.env` do backend tem:
```
FIREBASE_PROJECT_ID=seu-projeto-firebase
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@seu-projeto.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

## 5. Testar

```bash
cd Polys-Mobile
flutter run
```

O botão "Entrar com Google" aparecerá nas telas de Login e Registro.
