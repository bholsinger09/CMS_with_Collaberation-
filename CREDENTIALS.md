# Test Credentials

## Default Test Users

The database comes pre-populated with two test users:

### Admin User
- **Email:** `admin@cms.local`
- **Password:** `admin123`
- **Role:** Admin

### Editor User
- **Email:** `editor@cms.local`
- **Password:** `editor123`
- **Role:** Editor

## Creating New Accounts

You can also create new accounts using the **"Create an account"** link on the login page at http://localhost:3000/register

New users will be registered with the "Editor" role by default.

---

## Password Requirements

- Minimum 6 characters
- Passwords are hashed using SHA256 with Base64 encoding

---

## Quick Start

1. Navigate to http://localhost:3000
2. Click "Create an account" to register a new user, or
3. Use one of the test credentials above to sign in

After logging in, you'll have access to:
- Dashboard with content statistics
- Content management (create, edit, delete)
- Real-time collaboration features
- Content versioning
