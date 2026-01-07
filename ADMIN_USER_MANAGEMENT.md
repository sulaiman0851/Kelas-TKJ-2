# 👥 User Management Dashboard - Admin Panel

## Overview

Dashboard khusus **Admin** untuk mengelola user dan reset password.

### Features:
- ✅ View all users dengan roles
- ✅ Search & filter by role
- ✅ User statistics (total, admins, teachers, students)
- ✅ Reset password user
- ✅ Admin-only access (protected)

---

## 🚀 Setup

### 1. Get Service Role Key

```
1. Buka Supabase Dashboard
2. Settings → API
3. Copy "service_role" key (RAHASIA!)
4. Paste ke .env
```

### 2. Update `.env`

```bash
# Add this line:
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **PENTING**: Service role key adalah **SUPER ADMIN** key yang bisa bypass semua RLS policies. **JANGAN** commit ke Git atau share!

### 3. Restart Server

```bash
Ctrl+C
npm run dev
```

---

## 📋 Access

### URL:
```
http://localhost:4321/admin/users
```

### Requirements:
- ✅ Must be logged in
- ✅ Must have `admin` role

### If Not Admin:
- Redirect to `/dashboard`
- Cannot access page

---

## 🎯 Features

### 1. **User List**

Tampilkan semua user dengan:
- Avatar (initial username)
- Username & User ID
- Email
- Roles (admin/teacher/student)
- Status (Active)
- Join date
- Actions (Reset Password)

### 2. **Statistics**

Dashboard cards:
- **Total Users** - Semua user
- **Admins** - User dengan role admin
- **Teachers** - User dengan role teacher
- **Students** - User dengan role student

### 3. **Search & Filter**

- **Search**: Cari by username atau email
- **Filter**: Filter by role (All/Admin/Teacher/Student)
- **Refresh**: Reload data

### 4. **Reset Password**

Flow:
1. Klik "🔑 Reset Password" di user
2. Modal muncul
3. Input new password (min. 6 char)
4. Confirm password
5. Klik "Reset Password"
6. API call ke `/api/admin/reset-password`
7. Success notification

---

## 🔐 Security

### API Endpoint: `/api/admin/reset-password`

**Method**: POST

**Headers**:
```json
{
  "Content-Type": "application/json"
}
```

**Body**:
```json
{
  "userId": "uuid-here",
  "newPassword": "newpassword123"
}
```

**Response Success**:
```json
{
  "success": true,
  "message": "Password updated successfully",
  "user": { ... }
}
```

**Response Error**:
```json
{
  "error": "Error message here"
}
```

### Security Checks:

1. **Authentication** - Must be logged in
2. **Authorization** - Must be admin
3. **Validation** - Password min. 6 characters
4. **Service Role** - Uses Supabase admin client

---

## 📊 Database Queries

### Get All Users:
```typescript
const { data } = await supabase
  .from('profiles')
  .select(`
    *,
    user_roles(
      roles(name)
    )
  `)
  .order('created_at', { ascending: false });
```

### Check Admin:
```typescript
const { data: userRoles } = await supabase
  .from('user_roles')
  .select('*, roles(*)')
  .eq('user_id', userId);

const isAdmin = userRoles?.some(ur => ur.roles?.name === 'admin');
```

### Reset Password (Server-side):
```typescript
const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
  userId,
  { password: newPassword }
);
```

---

## 🎨 UI Components

### User Table Row:

```html
<tr>
  <td>
    <div class="avatar">A</div>
    <div>
      <div>Alice</div>
      <div>ID: abc123...</div>
    </div>
  </td>
  <td>alice@example.com</td>
  <td>
    <span class="badge admin">admin</span>
    <span class="badge teacher">teacher</span>
  </td>
  <td><span class="badge active">Active</span></td>
  <td>01/01/2026</td>
  <td>
    <button>🔑 Reset Password</button>
  </td>
</tr>
```

### Reset Modal:

```html
<div class="modal">
  <h2>Reset Password</h2>
  <div>User: Alice</div>
  <form>
    <input type="password" placeholder="New password" />
    <input type="password" placeholder="Confirm password" />
    <button>Reset Password</button>
  </form>
</div>
```

---

## 🧪 Testing

### Test Cases:

1. **Access Control**
   - Login as non-admin → Should redirect
   - Login as admin → Should show dashboard

2. **User List**
   - Should show all users
   - Should show correct roles
   - Should show stats

3. **Search**
   - Search "alice" → Should filter
   - Search "admin" → Should filter by email/username

4. **Filter**
   - Select "Admin" → Show only admins
   - Select "Student" → Show only students

5. **Reset Password**
   - Input password < 6 chars → Error
   - Input mismatched passwords → Error
   - Input valid password → Success
   - Check user can login with new password

---

## ⚠️ Important Notes

### Service Role Key:

**DO NOT**:
- ❌ Commit to Git
- ❌ Share publicly
- ❌ Use in client-side code
- ❌ Expose in frontend

**DO**:
- ✅ Keep in `.env` (gitignored)
- ✅ Use only in server-side API
- ✅ Rotate if compromised
- ✅ Limit access to admins only

### Password Reset:

- User will be **logged out** after password reset
- User must login with **new password**
- No email notification (can add later)
- Instant effect

---

## 🔧 Troubleshooting

### "Unauthorized" Error:
```
Problem: Not logged in
Solution: Login first
```

### "Forbidden: Admin only" Error:
```
Problem: User is not admin
Solution: 
1. Check user_roles table
2. Assign admin role to user
```

### "Cannot find service_role key" Error:
```
Problem: SUPABASE_SERVICE_ROLE_KEY not in .env
Solution:
1. Get key from Supabase Dashboard
2. Add to .env
3. Restart server
```

### Reset Password Fails:
```
Problem: API error
Solution:
1. Check console for error
2. Verify service_role key is correct
3. Check user ID is valid
4. Check password meets requirements
```

---

## 🚀 Future Enhancements

### Planned Features:

1. **Bulk Actions**
   - Select multiple users
   - Bulk reset password
   - Bulk assign roles

2. **User Details**
   - Click user → View details
   - Activity log
   - Login history

3. **Role Management**
   - Add/remove roles
   - Create custom roles
   - Permission matrix

4. **Email Notifications**
   - Send email on password reset
   - Welcome email for new users
   - Activity alerts

5. **Export**
   - Export user list to CSV
   - Generate reports
   - Analytics dashboard

---

## 📚 Related Files

```
src/pages/admin/users.astro          - Main dashboard page
src/pages/api/admin/reset-password.ts - API endpoint
.env.example                          - Environment template
```

---

**Admin Dashboard Ready! 🎉**

Access: `/admin/users` (Admin only)
