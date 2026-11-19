USE ReUseHubDB;
GO

/* Idempotent sample listings and requests for local demonstrations. */
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @OwnerID INT;
DECLARE @RequesterA INT;
DECLARE @RequesterB INT;
DECLARE @BooksCategoryID INT;
DECLARE @ElectronicsCategoryID INT;
DECLARE @StudyCategoryID INT;
DECLARE @BookResourceID INT;
DECLARE @CalculatorResourceID INT;
DECLARE @StationeryResourceID INT;
DECLARE @StandResourceID INT;

SELECT TOP 1 @OwnerID=UserID FROM Users WHERE ISNULL(IsAdmin,0)=0 ORDER BY UserID;
SELECT TOP 1 @RequesterA=UserID FROM Users WHERE ISNULL(IsAdmin,0)=0 AND UserID<>@OwnerID ORDER BY UserID;
SELECT TOP 1 @RequesterB=UserID FROM Users WHERE ISNULL(IsAdmin,0)=0 AND UserID<>@OwnerID AND UserID<>@RequesterA ORDER BY UserID;
SELECT @BooksCategoryID=MIN(CategoryID) FROM Categories WHERE CategoryName='Books';
SELECT @ElectronicsCategoryID=MIN(CategoryID) FROM Categories WHERE CategoryName='Electronics';
SELECT @StudyCategoryID=MIN(CategoryID) FROM Categories WHERE CategoryName='Study Materials';

IF @OwnerID IS NULL OR @RequesterA IS NULL OR @BooksCategoryID IS NULL OR @ElectronicsCategoryID IS NULL OR @StudyCategoryID IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR('Demo data requires one normal owner, one other normal user, and the Books, Electronics and Study Materials categories.',16,1);
    RETURN;
END;

/* Repair two existing listings whose uploaded image files are missing. */
UPDATE Resources SET ImagePath='Images/no-image.png'
WHERE ImagePath IN ('Images/3ab0b887-1bc3-438f-a99d-d4188a72b429.jpg','Images/6d6e0a4c-a757-4c50-a416-9c7dd37e10ab.jpg');

/* Replace the fallback shown for the existing Sports Kit listing with its matching local artwork. */
UPDATE Resources SET ImagePath='Images/demo-sports-kit.png'
WHERE ResourceName='Sports Kit' AND ImagePath='Images/no-image.png';

IF NOT EXISTS (SELECT 1 FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Book Bundle')
    INSERT INTO Resources(UserID,CategoryID,ResourceName,Description,ItemCondition,ResourceType,Status,CreatedDate,ImagePath,ImagePath2,ImagePath3)
    VALUES(@OwnerID,@BooksCategoryID,'ReUseHub Demo - Book Bundle','A small bundle of useful study and reference books, ready for a new reader.','Good','Donate','Available',GETDATE(),'Images/books.jpg',NULL,NULL);

IF NOT EXISTS (SELECT 1 FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Scientific Calculator')
    INSERT INTO Resources(UserID,CategoryID,ResourceName,Description,ItemCondition,ResourceType,Status,CreatedDate,ImagePath,ImagePath2,ImagePath3)
    VALUES(@OwnerID,@ElectronicsCategoryID,'ReUseHub Demo - Scientific Calculator','A tested scientific calculator for classes and homework.','Good','Lend','Available',GETDATE(),'Images/calculator.jpg',NULL,NULL);

IF NOT EXISTS (SELECT 1 FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Stationery Set')
    INSERT INTO Resources(UserID,CategoryID,ResourceName,Description,ItemCondition,ResourceType,Status,CreatedDate,ImagePath,ImagePath2,ImagePath3)
    VALUES(@OwnerID,@StudyCategoryID,'ReUseHub Demo - Stationery Set','Reusable notebooks, folders and stationery looking for another student.','Like New','Donate','Available',GETDATE(),'Images/demo-stationery.png',NULL,NULL);

IF NOT EXISTS (SELECT 1 FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Laptop Stand')
    INSERT INTO Resources(UserID,CategoryID,ResourceName,Description,ItemCondition,ResourceType,Status,CreatedDate,ImagePath,ImagePath2,ImagePath3)
    VALUES(@OwnerID,@ElectronicsCategoryID,'ReUseHub Demo - Laptop Stand','A compact stand to make a home or study desk more comfortable.','Good','Lend','Available',GETDATE(),'Images/demo-laptop-stand.png',NULL,NULL);

UPDATE Resources SET ImagePath='Images/demo-stationery.png'
WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Stationery Set';
UPDATE Resources SET ImagePath='Images/demo-laptop-stand.png'
WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Laptop Stand';

SELECT TOP 1 @BookResourceID=ResourceID FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Book Bundle' ORDER BY ResourceID DESC;
SELECT TOP 1 @CalculatorResourceID=ResourceID FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Scientific Calculator' ORDER BY ResourceID DESC;
SELECT TOP 1 @StationeryResourceID=ResourceID FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Stationery Set' ORDER BY ResourceID DESC;
SELECT TOP 1 @StandResourceID=ResourceID FROM Resources WHERE UserID=@OwnerID AND ResourceName='ReUseHub Demo - Laptop Stand' ORDER BY ResourceID DESC;

IF NOT EXISTS (SELECT 1 FROM Requests WHERE ResourceID=@BookResourceID AND RequesterID=@RequesterA)
BEGIN
    INSERT INTO Requests(ResourceID,RequesterID,OwnerID,Message,RequestDate,Status,DeliveryAddress,DeliveryStatus,DeliveryMethod)
    VALUES(@BookResourceID,@RequesterA,@OwnerID,'I would like to reuse these books if they are still available.',GETDATE(),'Pending','Self Pickup','Preparing','Pickup');
    INSERT INTO Notifications(UserID,Message) VALUES(@OwnerID,'New request received for ReUseHub Demo - Book Bundle.');
END;

IF @RequesterB IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Requests WHERE ResourceID=@CalculatorResourceID AND RequesterID=@RequesterB)
BEGIN
    INSERT INTO Requests(ResourceID,RequesterID,OwnerID,Message,RequestDate,Status,DeliveryAddress,DeliveryStatus,DeliveryMethod)
    VALUES(@CalculatorResourceID,@RequesterB,@OwnerID,'Could I borrow the calculator for my coursework?',GETDATE(),'Pending','Self Pickup','Preparing','Pickup');
    INSERT INTO Notifications(UserID,Message) VALUES(@OwnerID,'New request received for ReUseHub Demo - Scientific Calculator.');
END;

IF NOT EXISTS (SELECT 1 FROM Requests WHERE ResourceID=@StationeryResourceID AND RequesterID=@RequesterA)
BEGIN
    INSERT INTO Requests(ResourceID,RequesterID,OwnerID,Message,RequestDate,Status,DeliveryAddress,DeliveryStatus,DeliveryMethod)
    VALUES(@StationeryResourceID,@RequesterA,@OwnerID,'The stationery set would be useful for my next term.',GETDATE(),'Pending','Self Pickup','Preparing','Pickup');
    INSERT INTO Notifications(UserID,Message) VALUES(@OwnerID,'New request received for ReUseHub Demo - Stationery Set.');
END;

COMMIT TRANSACTION;
GO
