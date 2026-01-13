# Player Registration Implementation

## Overview
Implemented a complete player registration system integrated with the backend API.

## What Was Created

### 1. Models (`lib/models/`)
- **bowling_type_model.dart**: Model for bowling types (RF, RMF, RM, etc.)
- **player_model.dart**: Complete player model with address and bowling types

### 2. API Service Updates (`lib/services/api/api_service.dart`)
Added the following methods:
- `getBowlingTypes()`: Fetch all bowling types from API
- `uploadProfilePicture(filePath)`: Upload player profile picture
- `registerPlayer(...)`: Register a new player profile
- `getAllPlayers(...)`: Get all players with optional filters
- `getPlayerById(id)`: Get specific player details

### 3. Player Registration View (`lib/views/players/register_player_view.dart`)
A comprehensive multi-section form with:

#### Features:
- **Profile Picture Upload**: Optional image picker and upload
- **Personal Information**:
  - First Name (required)
  - Last Name (required)
  - Gender (MALE, FEMALE, OTHER)
  - Date of Birth (required, date picker)

- **Player Details**:
  - Player Type (BATSMAN, BOWLER, ALL_ROUNDER)
  - Wicket Keeper checkbox
  - Batting Hand (LEFT, RIGHT)
  - Bowling Hand (optional)
  - Bowling Types (multi-select chips)

- **Address**:
  - Street (optional)
  - Town/Suburb (optional)
  - City (required)
  - State/Province (required)
  - Country (required)
  - Postal Code (optional)

#### Validation:
- All required fields validated
- Date of birth must be selected
- At least one bowling type must be selected
- Form validation on submit

#### User Experience:
- Loading states for async operations
- Error handling with snackbar messages
- Success feedback
- Auto-navigation back on success
- Disabled form during submission
- Profile picture preview

## API Integration

### Endpoints Used:
1. `GET /api/v1/bowling-types` - Fetch bowling types (on page load)
2. `POST /api/v1/players/upload-profile-picture` - Upload image (optional)
3. `POST /api/v1/players/register` - Register player profile

### Authentication:
- All player endpoints require authentication
- Access token automatically included in headers
- Token refresh handled automatically on 401 errors

## Dependencies Added
- `image_picker: ^1.1.2` - For profile picture selection

## How to Use

1. User must be logged in
2. Navigate to drawer menu → Players → Register as Player
3. Fill in all required fields:
   - Personal information
   - Player details
   - Bowling types
   - Address
4. Optionally upload profile picture
5. Submit form
6. On success, navigate back to previous screen

## API Data Format

```json
{
  "firstName": "Virat",
  "lastName": "Kohli",
  "gender": "MALE",
  "dateOfBirth": "1988-11-05",
  "profilePicture": "http://localhost:3000/uploads/profile-pictures/abc123.jpg",
  "playerType": "BATSMAN",
  "isWicketKeeper": false,
  "batHand": "RIGHT",
  "bowlHand": "RIGHT",
  "bowlingTypeIds": ["uuid-1", "uuid-2"],
  "address": {
    "street": "123 Cricket Lane",
    "townSuburb": "Andheri",
    "city": "Mumbai",
    "state": "Maharashtra",
    "country": "India",
    "postalCode": "400053"
  }
}
```

## Error Handling
- Network errors displayed with snackbar
- Validation errors shown inline
- API errors formatted and displayed
- Session expiry handled with token refresh

## Future Enhancements
- Add form progress indicator
- Implement multi-step wizard
- Add country picker dropdown
- Implement camera capture for profile picture
- Add image cropping functionality
- Cache bowling types locally
