ReUseHub Feature Upgrade

Run FeatureUpgrade.sql in SQL Server Management Studio against ReUseHubDB before testing.
The script is idempotent for the added columns/tables and makes UserID=1 the initial admin.

10 features included:
1 Free delivery + tracking
2 Pickup / delivery choice
3 Rating and review after Delivered
4 Notifications
5 Wishlist
6 Advanced search/filter including owner location
7 Up to 3 resource images
8 Report resource
9 Admin dashboard
10 ReUseHub Impact dashboard

Expected demo flow:
User A lists item with up to 3 images -> User B explores and filters -> opens details -> saves wishlist -> chooses Free Delivery or Self Pickup -> requests -> User A approves -> User B sees Preparing -> Out for Delivery -> Delivered -> User B rates/reviews.
Reports appear in Admin Dashboard. Request/approval/delivery events create notifications.
