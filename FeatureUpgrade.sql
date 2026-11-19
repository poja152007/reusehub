USE ReUseHubDB;
GO

IF COL_LENGTH('dbo.Requests','DeliveryAddress') IS NULL
    ALTER TABLE Requests ADD DeliveryAddress VARCHAR(250) NULL;
GO
IF COL_LENGTH('dbo.Requests','DeliveryStatus') IS NULL
    ALTER TABLE Requests ADD DeliveryStatus VARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.Requests','DeliveryMethod') IS NULL
    ALTER TABLE Requests ADD DeliveryMethod VARCHAR(30) NULL;
GO
IF COL_LENGTH('dbo.Resources','ImagePath2') IS NULL
    ALTER TABLE Resources ADD ImagePath2 VARCHAR(250) NULL;
GO
IF COL_LENGTH('dbo.Resources','ImagePath3') IS NULL
    ALTER TABLE Resources ADD ImagePath3 VARCHAR(250) NULL;
GO
IF COL_LENGTH('dbo.Users','IsAdmin') IS NULL
    ALTER TABLE Users ADD IsAdmin BIT NOT NULL CONSTRAINT DF_Users_IsAdmin DEFAULT 0;
GO

IF OBJECT_ID('dbo.Wishlists','U') IS NULL
BEGIN
    CREATE TABLE Wishlists(
        WishlistID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        ResourceID INT NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_Wishlists_User_Resource UNIQUE(UserID, ResourceID)
    );
END
GO

IF OBJECT_ID('dbo.Notifications','U') IS NULL
BEGIN
    CREATE TABLE Notifications(
        NotificationID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        Message VARCHAR(500) NOT NULL,
        IsRead BIT NOT NULL DEFAULT 0,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

IF OBJECT_ID('dbo.Reviews','U') IS NULL
BEGIN
    CREATE TABLE Reviews(
        ReviewID INT IDENTITY(1,1) PRIMARY KEY,
        RequestID INT NOT NULL,
        ResourceID INT NOT NULL,
        ReviewerID INT NOT NULL,
        Rating INT NOT NULL,
        ReviewText VARCHAR(1000) NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_Reviews_Request UNIQUE(RequestID),
        CONSTRAINT CK_Reviews_Rating CHECK(Rating BETWEEN 1 AND 5)
    );
END
GO

IF OBJECT_ID('dbo.ResourceReports','U') IS NULL
BEGIN
    CREATE TABLE ResourceReports(
        ReportID INT IDENTITY(1,1) PRIMARY KEY,
        ResourceID INT NOT NULL,
        ReporterID INT NOT NULL,
        Reason VARCHAR(500) NOT NULL,
        ReportStatus VARCHAR(30) NOT NULL DEFAULT 'Pending',
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- Make the existing first test account the initial administrator.
-- Change the UserID below if a different account should be the admin.
IF EXISTS(SELECT 1 FROM Users WHERE UserID = 1)
    UPDATE Users SET IsAdmin = 1 WHERE UserID = 1;
GO
