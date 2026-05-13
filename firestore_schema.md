# Nearend – Firestore Schema

## Collections

### `users/{userId}`
```
{
  name: string,
  email: string,
  phoneNumber: string | null,
  profileImageUrl: string | null,
  bio: string | null,
  city: string | null,
  area: string | null,
  latitude: number | null,
  longitude: number | null,
  rating: number,           // 0.0 – 5.0
  ratingsCount: number,
  listingsCount: number,
  trustScore: number,       // 0 – 100
  role: 'user' | 'admin',
  isVerified: boolean,
  isBlocked: boolean,
  isOnline: boolean,
  createdAt: Timestamp,
  lastSeen: Timestamp | null,
}
```
**Indexes:** none required (queries by UID)

---

### `listings/{listingId}`
```
{
  title: string,
  description: string,
  imageUrls: string[],
  sellPrice: number | null,
  rentPricePerDay: number | null,
  isForExchange: boolean,
  category: string,
  condition: string,
  listingType: 'sell' | 'rent' | 'exchange',
  isAvailable: boolean,
  sellerId: string,
  sellerName: string,
  sellerImageUrl: string | null,
  sellerRating: number,
  latitude: number,
  longitude: number,
  city: string | null,
  area: string | null,
  viewCount: number,
  favoriteCount: number,
  isReported: boolean,
  createdAt: Timestamp,
  updatedAt: Timestamp,
}
```
**Indexes required:**
- `isAvailable ASC, latitude ASC` (nearby queries)
- `sellerId ASC, createdAt DESC` (user listings)
- `isAvailable ASC, viewCount DESC` (trending)
- `isAvailable ASC, category ASC, createdAt DESC` (category filter)

---

### `chats/{chatId}`
```
{
  participantIds: string[],           // [userId1, userId2]
  participantNames: Map<string, string>,
  participantImages: Map<string, string | null>,
  listingId: string | null,
  listingTitle: string | null,
  listingImageUrl: string | null,
  lastMessage: string,
  lastMessageSenderId: string,
  lastMessageTime: Timestamp,
  unreadCount: Map<string, number>,   // { userId: count }
}
```
**Indexes required:**
- `participantIds ARRAY_CONTAINS, lastMessageTime DESC`

---

### `chats/{chatId}/messages/{messageId}`
```
{
  chatId: string,
  senderId: string,
  senderName: string,
  content: string,
  type: 'text' | 'image',
  isRead: boolean,
  createdAt: Timestamp,
}
```
**Indexes required:**
- `createdAt DESC` (default message ordering)

---

### `favorites/{favoriteId}`
```
{
  userId: string,
  listingId: string,
  createdAt: Timestamp,
}
```
**Indexes required:**
- `userId ASC, listingId ASC`

---

### `reports/{reportId}`
```
{
  listingId: string,
  reason: string,
  reporterId: string,
  createdAt: Timestamp,
  resolved: boolean,
}
```

---

### `notifications/{notificationId}`
```
{
  userId: string,
  title: string,
  body: string,
  type: 'message' | 'nearby_listing' | 'favorite_update' | 'rental_request',
  data: Map<string, dynamic>,
  isRead: boolean,
  createdAt: Timestamp,
}
```
**Indexes required:**
- `userId ASC, createdAt DESC`
