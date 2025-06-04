# 🚀 AWS Migration Guide for Diary App

## Overview
This guide will help you migrate your Flutter diary app from Firebase to AWS services.

## Service Mapping & Migration Plan

### 1. Authentication: Firebase Auth → AWS Cognito
**Current**: Firebase Authentication with Google/GitHub
**New**: AWS Cognito User Pools + Identity Pools

### 2. Database: Cloud Firestore → AWS DynamoDB
**Current**: Real-time NoSQL database
**New**: High-performance NoSQL database with streams

### 3. Storage: Cloud Storage → AWS S3
**Current**: File storage (if used)
**New**: Object storage for any files/images

## Step-by-Step Migration

### Phase 1: Setup AWS Services

#### 1.1 Create AWS Account & Install CLI
```bash
# Install AWS CLI
# Download from: https://aws.amazon.com/cli/

# Configure AWS credentials
aws configure
```

#### 1.2 Install AWS Amplify CLI
```bash
npm install -g @aws-amplify/cli
amplify configure
```

#### 1.3 Initialize Amplify in Your Project
```bash
cd c:\Users\luizr\AndroidStudioProjects\diary_app
amplify init
```

### Phase 2: Setup Authentication (AWS Cognito)

#### 2.1 Add Cognito Authentication
```bash
amplify add auth
```
Choose:
- Default configuration with Social Provider
- Username
- Email, Password
- Google, GitHub (social providers)

#### 2.2 Configure Social Providers
```bash
amplify update auth
```

### Phase 3: Setup Database (DynamoDB)

#### 3.1 Add API & Database
```bash
amplify add api
```
Choose:
- GraphQL
- Amazon Cognito User Pool (for auth)
- Single object with fields

#### 3.2 Create Schema
Create `amplify/backend/api/diaryapp/schema.graphql`:
```graphql
type DiaryEntry @model @auth(rules: [{allow: owner}]) {
  id: ID!
  title: String!
  content: String!
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
  owner: String
}
```

### Phase 4: Update Flutter Dependencies

#### 4.1 Replace Firebase Dependencies
Remove from `pubspec.yaml`:
```yaml
# Remove these
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.13.6
google_sign_in: ^6.1.6
```

Add AWS dependencies:
```yaml
dependencies:
  # AWS Amplify packages
  amplify_flutter: ^1.5.0
  amplify_auth_cognito: ^1.5.0
  amplify_api: ^1.5.0
  amplify_datastore: ^1.5.0
  
  # For social sign-in
  amplify_authenticator: ^1.5.0
```

#### 4.2 Install Dependencies
```bash
flutter pub get
```

### Phase 5: Update Code

#### 5.1 Update main.dart
```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MyApp());
}

Future<void> _configureAmplify() async {
  try {
    final authPlugin = AmplifyAuthCognito();
    final apiPlugin = AmplifyAPI();
    final dataStorePlugin = AmplifyDataStore(modelProvider: ModelProvider.instance);
    
    await Amplify.addPlugins([authPlugin, apiPlugin, dataStorePlugin]);
    await Amplify.configure(amplifyconfig);
    
    print('Successfully configured Amplify');
  } catch (e) {
    print('Error configuring Amplify: $e');
  }
}
```

#### 5.2 Create AWS Auth Service
```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AWSAuthService {
  // Sign in with username/password
  Future<SignInResult> signIn(String username, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      return result;
    } on AuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    }
  }

  // Sign up
  Future<SignUpResult> signUp(String username, String password, String email) async {
    try {
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: email,
          },
        ),
      );
      return result;
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  // Social sign-in (Google/GitHub)
  Future<SignInResult> signInWithSocialProvider(AuthProvider provider) async {
    try {
      final result = await Amplify.Auth.signInWithWebUI(provider: provider);
      return result;
    } on AuthException catch (e) {
      throw Exception('Social sign in failed: ${e.message}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      print('Sign out failed: ${e.message}');
    }
  }

  // Get current user
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  // Check if signed in
  Future<bool> isSignedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}
```

#### 5.3 Create AWS Diary Service
```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/DiaryEntry.dart';

class AWSDiaryService {
  // Get all diary entries
  Stream<List<DiaryEntry>> getDiaryEntries() {
    return Amplify.DataStore.observeQuery(DiaryEntry.classType)
        .map((event) => event.items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Create diary entry
  Future<void> createDiaryEntry(String title, String content) async {
    try {
      final entry = DiaryEntry(
        title: title,
        content: content,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );
      
      await Amplify.DataStore.save(entry);
    } catch (e) {
      throw Exception('Failed to create diary entry: $e');
    }
  }

  // Update diary entry
  Future<void> updateDiaryEntry(DiaryEntry entry, String title, String content) async {
    try {
      final updatedEntry = entry.copyWith(
        title: title,
        content: content,
        updatedAt: TemporalDateTime.now(),
      );
      
      await Amplify.DataStore.save(updatedEntry);
    } catch (e) {
      throw Exception('Failed to update diary entry: $e');
    }
  }

  // Delete diary entry
  Future<void> deleteDiaryEntry(DiaryEntry entry) async {
    try {
      await Amplify.DataStore.delete(entry);
    } catch (e) {
      throw Exception('Failed to delete diary entry: $e');
    }
  }
}
```

### Phase 6: Deploy to AWS

#### 6.1 Deploy Backend
```bash
amplify push
```

#### 6.2 Generate Models
```bash
amplify codegen models
```

### Phase 7: Update UI Components

#### 7.1 Replace FirebaseSetupChecker
```dart
class AWSSetupChecker extends StatelessWidget {
  final Widget child;

  const AWSSetupChecker({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAWSSetup(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing AWS Services...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('AWS Setup Error: ${snapshot.error}'),
            ),
          );
        }

        return child;
      },
    );
  }

  Future<bool> _checkAWSSetup() async {
    try {
      await Amplify.Auth.getCurrentUser();
      return true;
    } catch (e) {
      return true; // AWS is configured even if user not signed in
    }
  }
}
```

## Cost Comparison

### Firebase Pricing
- Authentication: Free for first 50K users/month
- Firestore: $0.18 per 100K reads, $0.18 per 100K writes
- Storage: $0.026/GB/month

### AWS Pricing  
- Cognito: $0.0055 per MAU after 50K free
- DynamoDB: $0.25 per million reads, $1.25 per million writes
- S3: $0.023/GB/month

## Benefits of AWS Migration

### Pros:
✅ **Enterprise Scale**: Better for large applications
✅ **More Services**: Wider range of AWS services available
✅ **Cost Control**: Often cheaper at scale
✅ **Compliance**: Better compliance options
✅ **Integration**: Seamless with other AWS services

### Cons:
❌ **Complexity**: More complex setup
❌ **Learning Curve**: Steeper learning curve
❌ **Real-time**: Requires additional setup for real-time features

## Migration Timeline

**Week 1**: Setup AWS account and Amplify CLI
**Week 2**: Configure authentication and database
**Week 3**: Update Flutter code and test
**Week 4**: Deploy and migrate data

## Next Steps

1. **Create AWS Account**: Sign up at https://aws.amazon.com
2. **Install AWS CLI & Amplify CLI**
3. **Follow this guide step by step**
4. **Test thoroughly before switching**
5. **Consider running both systems in parallel during transition**

## Need Help?

- AWS Amplify Documentation: https://docs.amplify.aws/
- AWS Amplify Flutter: https://docs.amplify.aws/lib/q/platform/flutter/
- AWS Support: Available with paid plans

Would you like me to start implementing any of these changes?
