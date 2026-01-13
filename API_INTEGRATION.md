# Cricket Spirit - API Integration Guide

## ✅ Complete Authentication Flow Implemented

All authentication endpoints from API documentation are now fully integrated with real REST API calls.

---

## 🔌 API Service Setup

### **Base Configuration**
File: `lib/services/api/api_service.dart`

```dart
static const String baseUrl = 'http://localhost:3000';
```

**✅ Updated to match API documentation structure**  
**TODO:** Update `baseUrl` with your actual backend URL before deploying.

---

## 🔐 Authentication APIs (Implemented)

### **1. Register** ✅
**Endpoint:** `POST /auth/register`

**Request:**
```json
{
  "email": "john@example.com",
  "name": "John Doe",
  "password": "securePass123"
}
```

**Response:**
```json
{
  "message": "Registration initiated. Please check your email for the verification OTP.",
  "data": {
    "email": "john@example.com",
    "name": "John Doe"
  }
}
```

**Implementation:** `lib/views/auth/register_view.dart` → `_attemptRegister()`

---

### **2. Verify Email** ✅
**Endpoint:** `POST /auth/verify-email`

**Request:**
```json
{
  "email": "john@example.com",
  "otp": "582746"
}
```

**Response:**
```json
{
  "message": "Email verified successfully. You can now login.",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john@example.com",
    "name": "John Doe",
    "role": "USER",
    "isEmailVerified": true,
    "createdAt": "2026-01-11T13:25:00.000Z"
  }
}
```

**Implementation:** `lib/views/auth/register_view.dart` → `_verifyOtp()`

---

### **3. Resend OTP** ✅
**Endpoint:** `POST /auth/resend-verification-otp`

**Request:**
```json
{
  "email": "john@example.com"
}
```

**Response:**
```json
{
  "message": "Verification OTP has been resent to your email."
}
```

**Implementation:** `lib/views/auth/register_view.dart` → `_resendOtp()`

---

### **4. Login** ✅
**Endpoint:** `POST /auth/login`

**Request:**
```json
{
  "email": "john@example.com",
  "password": "securePass123"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "john@example.com",
      "name": "John Doe",
      "role": "USER",
      "isEmailVerified": true,
      "createdAt": "2026-01-11T13:25:00.000Z"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

**Implementation:** `lib/views/auth/login_view.dart` → `_submit()`

**Features:**
- Automatically stores `accessToken` and `refreshToken`
- Saves user data to `appState.currentUser`
- Shows welcome message with user name
- Redirects to home screen

---

## 🎨 Complete UI Flows Implemented

### **Registration Flow** ✅
**File:** `lib/views/auth/register_view.dart`

**Step 1: Registration Form**
- Email, name, password inputs
- Form validation
- "Send Verification Code" button
- Link to login

**Step 2: OTP Verification**
- Email display
- 6-digit OTP input
- Verify button
- Resend OTP link
- Change email option

---

### **Login Flow** ✅
**File:** `lib/views/auth/login_view.dart`

- Email and password inputs
- Form validation
- "Forgot Password?" link
- Login button
- Google sign-in option (placeholder)
- Link to registration

---

### **Forgot Password Flow** ✅
**File:** `lib/views/auth/forgot_password_view.dart`

**Step 1: Email Entry**
- Email input
- "Send Reset OTP" button
- Back to login link

**Step 2: Reset Password**
- OTP input (6 digits)
- New password input
- Confirm password input
- Reset password button
- Resend OTP link
- Change email option

---

### **Profile View** ✅
**File:** `lib/views/auth/profile_view.dart`

- Auto-fetch user data on load
- User avatar with initials
- Name, email, role display
- Member since date
- Refresh button
- Glassmorphism design
- Loading and error states
- Logout functionality

---

## 💾 State Management

### **App State** (`lib/app/app_state.dart`)

**Properties:**
- `bool hasSeenOnboarding` - Onboarding completion status
- `bool isLoggedIn` - User authentication status
- `UserModel? currentUser` - Current user data from API

**Methods:**
- `login({UserModel? user})` - Login user and store data
- `updateUser(UserModel user)` - Update current user data
- `logout()` - Clear all user data and tokens

---

## 📦 User Model (`lib/models/user_model.dart`)

```dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Helper methods
  String getMemberSince(); // Returns "January 2026"
  String getInitials();    // Returns "JD" from "John Doe"
}
```

---

## 🎨 Profile Page (Updated)

### **Design Changes:**
- ✅ **Removed background gradients** - Plain dark background
- ✅ **Removed animated circles** - Clean, minimal design
- ✅ **Removed stats cards** - Only showing data from API
- ✅ **Kept glassmorphism effects** - On cards and dialogs

### **Data Displayed:**
From `appState.currentUser`:
- User avatar (initials)
- Full name
- Email address
- Role badge
- Member since date

### **States:**
1. **Loading** - Shows spinner while fetching data
2. **Error** - Shows error message with retry button
3. **Success** - Shows user profile data

### **Actions:**
- Refresh button - Refetch profile data
- Settings button - Placeholder
- Edit Profile - Placeholder
- Match History - Placeholder
- Statistics - Placeholder
- Notifications - Placeholder
- **Logout** - Full implementation with confirmation

---

## 🔒 Token Management

**Storage:**
- `accessToken` - Stored in `apiService` instance
- `refreshToken` - Stored in `apiService` instance
- Cleared on logout

**Headers:**
All authenticated requests automatically include:
```
Authorization: Bearer {accessToken}
```

---

## ⚠️ Error Handling

### **All API calls handle:**
- Network errors
- Invalid responses
- Authentication errors
- Server errors

### **User feedback via:**
- Snackbars for errors (red background)
- Snackbars for success (lime green background)
- Error screens with retry buttons
- Loading indicators

---

## 🧪 Testing the Integration

### **1. Start Your Backend**
```bash
# Make sure your backend is running on the configured baseUrl
npm run dev  # or your start command
```

### **2. Update Base URL (if needed)**
```dart
// lib/services/api/api_service.dart
static const String baseUrl = 'http://your-backend-url/api';
```

### **3. Test Registration Flow**
1. Open app → Skip onboarding → Click "Sign Up"
2. Enter email, name, password → "Send Verification Code"
3. Check email for OTP
4. Enter OTP → "Verify & Continue"
5. Should see success message and redirect to login

### **4. Test Login Flow**
1. Enter email and password → "Login"
2. Should see welcome message
3. Should redirect to home screen
4. User data stored in `appState.currentUser`

### **5. Test Profile Page**
1. Navigate to Profile (bottom nav)
2. Should see loading spinner
3. Should fetch and display user data
4. Try refresh button
5. Try logout

---

## 📝 Next Steps

### **✅ Implemented:**
- [x] Complete registration flow with OTP
- [x] Email verification
- [x] Login with token management
- [x] Forgot password flow (2-step)
- [x] Reset password with OTP
- [x] Automatic token refresh on 401
- [x] Get current user profile
- [x] Error handling with message formatting
- [x] Loading states on all forms
- [x] Form validation on all inputs

### **⏳ Pending:**
- [ ] Secure token storage (use `flutter_secure_storage`)
- [ ] Persistent login (save tokens to secure storage)
- [ ] Edit profile UI
- [ ] Google OAuth integration
- [ ] Match history endpoint integration
- [ ] Statistics endpoint integration

### **Backend Requirements:**
Make sure your backend implements:
- CORS headers for Flutter web
- All endpoints as documented above
- JWT token authentication
- OTP email sending
- Rate limiting on OTP endpoints

---

## 🚀 Deployment Checklist

Before deploying to production:

1. **Update API URL**
   ```dart
   static const String baseUrl = 'https://api.cricketspiritapp.com/api';
   ```

2. **Add Secure Storage**
   - Install `flutter_secure_storage` package
   - Store tokens securely
   - Implement auto-login

3. **Add Token Refresh**
   - Implement refresh token logic
   - Handle 401 errors automatically
   - Refresh tokens before expiry

4. **Environment Variables**
   - Move API URL to environment config
   - Different URLs for dev/staging/prod

5. **Error Tracking**
   - Add Sentry or similar
   - Log API errors
   - Track user issues

---

## 📚 Dependencies Added

```yaml
dependencies:
  http: ^1.2.0  # For API calls
```

---

---

## 📦 Files Structure

```
lib/
├── services/api/
│   └── api_service.dart         # Complete API service with all endpoints
├── models/
│   └── user_model.dart           # User data model with helpers
├── app/
│   └── app_state.dart            # Global state management
├── views/
│   ├── auth/
│   │   ├── login_view.dart       # Login screen
│   │   ├── register_view.dart    # Registration + OTP verification
│   │   └── forgot_password_view.dart  # Password reset flow
│   └── profile/
│       └── profile_view.dart     # User profile display
```

---

*Last Updated: January 11, 2026*  
*Status: ✅ **Complete Auth Flow - Ready for Testing***
