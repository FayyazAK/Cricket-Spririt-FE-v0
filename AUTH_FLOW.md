# Cricket Spirit - Authentication Flow

## 🔐 New OTP-Based Registration System

### Overview
Users are **NOT created in the database** until they verify their email with OTP. Registration data is stored temporarily in a `pending_registrations` table.

---

## 📱 Frontend Implementation

### **Registration Screen** (`register_view.dart`)

#### **Step 1: Registration Form**
- Email input (with validation)
- Full name input
- Password input (minimum 6 characters)
- "Send Verification Code" button
- "Continue with Google" option
- "Already have an account? Login" link

**On Submit:**
1. Validates all fields
2. Shows loading indicator
3. Calls `POST /auth/register` API
4. Backend stores in `pending_registrations` table
5. Backend sends 6-digit OTP to email
6. Transitions to OTP verification screen

---

#### **Step 2: OTP Verification Screen**
- Email icon at top
- Shows email address where OTP was sent
- 6-digit OTP input field (centered, large font)
- "Verify & Continue" button
- "Didn't receive the code? Resend" link
- "Change Email" link (goes back to registration form)

**Features:**
- OTP must be exactly 6 digits
- Shows "OTP expires in 15 minutes" helper text
- Loading states on verify and resend
- Success message on verification
- Navigates back to login after successful verification

---

### **Login Screen** (`login_view.dart`)

**Simplified to Email-Only:**
- Email input (with validation)
- Password input
- "Forgot Password?" link
- "Login" button with loading state
- "Continue with Google" option
- "Don't have an account? Sign Up" link

**On Submit:**
1. Validates email and password
2. Shows loading indicator
3. Calls `POST /auth/login` API
4. Stores access token and refresh token
5. Navigates to home screen

---

## 🔄 API Integration Points

### **1. Register (Step 1)**
```dart
// TODO: Implement API call
POST /auth/register
Body: {
  "email": "john@example.com",
  "name": "John Doe",
  "password": "securePass123"
}

Response: {
  "message": "Registration initiated. Please check your email for the verification OTP.",
  "data": {
    "email": "john@example.com",
    "name": "John Doe"
  }
}
```

### **2. Verify Email (Step 2)**
```dart
// TODO: Implement API call
POST /auth/verify-email
Body: {
  "email": "john@example.com",
  "otp": "582746"
}

Response: {
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

### **3. Resend OTP**
```dart
// TODO: Implement API call
POST /auth/resend-verification-otp
Body: {
  "email": "john@example.com"
}

Response: {
  "message": "Verification OTP has been resent to your email."
}
```

### **4. Login**
```dart
// TODO: Implement API call
POST /auth/login
Body: {
  "email": "john@example.com",
  "password": "securePass123"
}

Response: {
  "message": "Login successful",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "john@example.com",
      "name": "John Doe",
      "role": "USER",
      "isEmailVerified": true
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

---

## ✅ Current Status

### Completed Features:
- ✅ Two-step registration UI (form → OTP verification)
- ✅ Email-only login (removed phone option)
- ✅ Form validation for all fields
- ✅ OTP input with 6-digit validation
- ✅ Loading states for all async operations
- ✅ Resend OTP functionality
- ✅ Change email option
- ✅ Error handling UI
- ✅ Success messages with snackbars
- ✅ Navigation flow between screens

### Pending Backend Integration:
- ⏳ API service layer setup
- ⏳ HTTP client configuration
- ⏳ Token storage (secure storage)
- ⏳ Error response handling
- ⏳ Network error handling
- ⏳ Forgot password flow

---

## 🎨 UI/UX Features

### Registration:
- Clean, modern form design
- Icons for each input field
- Loading indicators on buttons
- Disabled state during API calls
- Email verification screen with large OTP input
- Clear feedback messages

### Login:
- Simplified email-only login
- Forgot password link
- Loading states
- Google sign-in option (placeholder)
- Easy navigation to registration

### Error Handling:
- Form validation messages
- API error snackbars
- Network error handling (to be implemented)
- OTP expiry handling

---

## 📧 Email Template (Backend Reference)

The backend should send emails with this structure:

**Subject:** Verify Your Email Address

**Body:**
```
Email Verification

Hello [Name],

Thank you for registering with Cricket Spirit. 
Please use the following OTP to verify your email address:

    [OTP CODE]
    (Large, centered, green #CDFF2F)

This OTP will expire in 15 minutes.

If you did not create an account, please ignore this email.

Best regards,
Cricket Spirit Team
```

---

## 🔒 Security Considerations

1. **Password Hashing:** Backend uses bcrypt
2. **OTP Expiry:** 15 minutes from generation
3. **OTP Storage:** Stored in `pending_registrations`, not in main `users` table
4. **Cleanup:** Pending registrations deleted after successful verification
5. **Rate Limiting:** Should be implemented on backend for OTP resend
6. **Token Security:** Access tokens should be stored securely (to be implemented)

---

## 📝 Next Steps

1. **Backend API Integration:**
   - Create API service layer
   - Implement HTTP client with interceptors
   - Add token management
   - Implement secure storage for tokens

2. **Error Handling:**
   - Add comprehensive error handling
   - Network connectivity checks
   - Retry mechanisms

3. **Additional Features:**
   - Forgot password flow
   - Google OAuth integration
   - Biometric authentication (optional)
   - Remember me functionality

---

## 🧪 Testing Checklist

### Registration Flow:
- [ ] Valid email format validation
- [ ] Name required validation
- [ ] Password minimum length validation
- [ ] OTP sent successfully
- [ ] OTP verification with valid code
- [ ] OTP verification with invalid code
- [ ] OTP expiry handling
- [ ] Resend OTP functionality
- [ ] Change email functionality
- [ ] Already registered email handling

### Login Flow:
- [ ] Valid email format validation
- [ ] Password required validation
- [ ] Successful login
- [ ] Invalid credentials handling
- [ ] Unverified email handling
- [ ] Token storage
- [ ] Auto-login with stored token

---

*Last Updated: January 11, 2026*
