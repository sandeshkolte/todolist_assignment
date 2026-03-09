# Tutorial 2026 - Flutter Task Management App

A Flutter application for task management with Supabase backend integration, featuring user authentication, theme switching, and real-time task management.

## Features

- 🔐 User Authentication (Login/Signup)
- 📝 Task Management (Create, Read, Update, Delete)
- 🎨 Light/Dark Theme Support
- 🔄 Real-time Updates
- 📱 Cross-platform (iOS, Android, Web, Desktop)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.11.1 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- A code editor (VS Code recommended with Flutter extension)
- [Git](https://git-scm.com/downloads)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd tutorial_2026
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Create a `.env` file in the root directory with your Supabase credentials:

```bash
cp .env.example .env
```

Edit the `.env` file with your actual Supabase project details:

```env
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 4. Run the App

#### For Android:
```bash
flutter run
```

#### For iOS (macOS only):
```bash
flutter run
```

#### For Web:
```bash
flutter run -d chrome
```

#### For Desktop (Windows/macOS/Linux):
```bash
flutter run -d windows  # or macos/linux
```

## Supabase Setup Steps

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create an account
2. Click "New Project"
3. Fill in your project details and wait for the database to be set up

### 2. Database Setup

#### Create the `tasks` table:

```sql
CREATE TABLE tasks (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Enable Row Level Security (RLS):

```sql
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
```

#### Create RLS Policies:

```sql
-- Allow users to view only their own tasks
CREATE POLICY "Users can view own tasks" ON tasks
  FOR SELECT USING (auth.uid() = user_id);

-- Allow users to insert their own tasks
CREATE POLICY "Users can insert own tasks" ON tasks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own tasks
CREATE POLICY "Users can update own tasks" ON tasks
  FOR UPDATE USING (auth.uid() = user_id);

-- Allow users to delete their own tasks
CREATE POLICY "Users can delete own tasks" ON tasks
  FOR DELETE USING (auth.uid() = user_id);
```

### 3. Authentication Configuration

1. In your Supabase dashboard, go to Authentication > Settings
2. Configure your site URL and redirect URLs for your app
3. Enable email confirmation if desired
4. Copy your project URL and anon key from Settings > API

### 4. Update Environment Variables

Add your Supabase credentials to the `.env` file as mentioned in the setup instructions.

## Hot Reload vs Hot Restart Explanation

### Hot Reload
Hot Reload is Flutter's feature that allows you to see changes in your app almost instantly without losing the current app state.

**When to use Hot Reload:**
- UI changes (colors, text, layouts)
- Adding new widgets
- Modifying existing widget properties
- Adding new methods or classes
- Most development changes

**How it works:**
- Injects updated source code into the running Dart VM
- Rebuilds the widget tree
- Preserves app state and navigation

**Keyboard shortcut:** `r` in terminal or `Ctrl+S` (VS Code with Flutter extension)

### Hot Restart
Hot Restart completely restarts your Flutter app, rebuilding everything from scratch.

**When to use Hot Restart:**
- Changes to `main()` function
- Changes to initialization code
- Adding/removing plugins or dependencies
- Changes to platform-specific code
- When Hot Reload doesn't work

**How it works:**
- Restarts the entire Flutter app
- Reinitializes all state
- Takes longer than Hot Reload

**Keyboard shortcut:** `R` (shift+r) in terminal or `Ctrl+Shift+F5` (VS Code)

### Key Differences

| Feature | Hot Reload | Hot Restart |
|---------|------------|-------------|
| Speed | Fast (~1 second) | Slower (~5-10 seconds) |
| State Preservation | Yes | No |
| Use Case | UI/Logic changes | App initialization changes |
| Keyboard Shortcut | `r` | `R` (Shift+R) |

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app/
│   └── theme.dart           # Theme definitions
├── auth/
│   ├── auth_gate.dart       # Authentication routing
│   ├── login_screen.dart    # Login screen
│   └── signup_screen.dart   # Signup screen
├── dashboard/
│   ├── dashboard_screen.dart # Main task screen
│   ├── task_model.dart      # Task data model
│   └── task_tile.dart       # Task list item widget
├── providers/
│   ├── auth_provider.dart   # Authentication state
│   ├── task_provider.dart   # Task management state
│   └── theme_provider.dart  # Theme state
├── services/
│   └── supabase_service.dart # Supabase API calls
├── utils/
│   └── validators.dart      # Input validation
└── widgets/                 # Reusable UI components
    ├── form_field.dart
    ├── primary_button.dart
    ├── task_tile.dart
    └── top_bar_button.dart
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

**App won't start:**
- Ensure all dependencies are installed: `flutter pub get`
- Check that your `.env` file exists and contains valid Supabase credentials
- Verify Supabase project is active and accessible

**Authentication issues:**
- Check that RLS policies are correctly set up in Supabase
- Ensure email confirmation is properly configured
- Verify the anon key is correct

**Hot Reload not working:**
- Save your files first
- Check for syntax errors in the terminal
- Try Hot Restart if Hot Reload fails

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
