-- ==========================
-- 🛍️ DATABASE: UtMyFashionStore
-- Author: Nguyễn Thị Diệu My
-- Description: Database cho hệ thống quản lý cửa hàng thời trang UtMy
-- ==========================

-- 1️⃣ Tạo database
-- CREATE DATABASE UtMyFashionStore;
-- GO

USE UtMyFashionStore;
GO

-- 1. Bảng lưu thông tin người dùng
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Username VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Role NVARCHAR(20) CHECK (Role IN ('ADMIN', 'CUSTOMER')) DEFAULT 'CUSTOMER',
    CreatedAt DATETIME DEFAULT GETDATE(),
	IsActive BIT DEFAULT 1,
    UpdatedAt DATETIME NULL
);
GO

-- 2. Bảng Address (Địa chỉ người dùng)
CREATE TABLE Address (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Phone NVARCHAR(20),
    Province VARCHAR(100),
    District VARCHAR(100),
    Ward VARCHAR(100),
    Detail VARCHAR(255),
    IsDefault BIT DEFAULT 0,
	FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- 3️. Bảng danh mục sản phẩm
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 4️. Bảng sản phẩm
CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId INT NOT NULL,
    ProductName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
	CurrentVersionID INT NULL,
    FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)

);
GO

-- 5. Bảng màu
CREATE TABLE Colors (
    ColorID INT IDENTITY(1,1) PRIMARY KEY,
    ColorName NVARCHAR(50) NOT NULL
);
GO

-- 6. Bảng kích thước
CREATE TABLE Sizes (
    SizeID INT IDENTITY(1,1) PRIMARY KEY,
    SizeName NVARCHAR(20) NOT NULL
);
GO

-- 7️. Bảng ProductVersions (Phiên bản sản phẩm - giá)
CREATE TABLE ProductVersions (
    VersionID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    VersionName NVARCHAR(100) NULL,  -- tên hoặc mã phiên bản, VD: "Đợt giá 2025", "Giá mùa hè"
    ImportPrice DECIMAL(12,2) NOT NULL,
    SellPrice DECIMAL(12,2) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

ALTER TABLE Products
ADD FOREIGN KEY (CurrentVersionID) REFERENCES ProductVersions(VersionID)
go

-- 8. 
CREATE TABLE ProductDetail (
    ProductDetailId INT IDENTITY(1,1) PRIMARY KEY,
    VersionID INT NOT NULL,
    ColorID INT NOT NULL,
    SizeID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (VersionID) REFERENCES ProductVersions(VersionID),
    FOREIGN KEY (ColorID) REFERENCES Colors(ColorID),
    FOREIGN KEY (SizeID) REFERENCES Sizes(SizeID)
);
GO

-- 9. Bảng lưu danh sách ảnh minh họa cho sản phẩm
CREATE TABLE ProductImage (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ImageUrl NVARCHAR(255) NOT NULL,   -- đường dẫn hoặc URL ảnh
    IsMain BIT DEFAULT 0,              -- ảnh chính (1) hay phụ (0)
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- 10. Bảng Supplier (Nhà cung cấp)
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(150) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(255)
);
GO

-- 11. Bảng ImportReceipts (Phiếu nhập hàng)
CREATE TABLE ImportReceipt (
    ImportID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT,
    CreatedBy INT,
    ImportDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- 12. Bảng ImportDetail (Chi tiết nhập hàng)
CREATE TABLE ImportDetail (
    ImportDetailID INT IDENTITY(1,1) PRIMARY KEY,
    ImportID INT NOT NULL,
    VersionID INT NOT NULL,
	ColorID INT NOT NULL,
    SizeID INT NOT NULL,
    ImportPrice DECIMAL(12,2) NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (ImportID) REFERENCES ImportReceipt(ImportID),
    FOREIGN KEY (VersionID) REFERENCES ProductVersions(VersionID),
	FOREIGN KEY (ColorID) REFERENCES Colors(ColorID),
    FOREIGN KEY (SizeID) REFERENCES Sizes(SizeID)
);
GO

-- 13. Bảng mã giảm giá (voucher)
CREATE TABLE Vouchers (
    VoucherId INT IDENTITY(1,1) PRIMARY KEY,
    Code NVARCHAR(50) UNIQUE NOT NULL,
    DiscountPercent INT CHECK (DiscountPercent BETWEEN 0 AND 100),
    StartDate DATE,
    EndDate DATE,
    IsActive BIT DEFAULT 1
);
GO

-- 14. 
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CreatedBy INT NULL,
    VoucherID INT NULL,
	Phone VARCHAR(20),
    DetailAddress NVARCHAR(MAX),
    OrderDate DATETIME DEFAULT GETDATE(),
	ShippingFee DECIMAL(12,2) DEFAULT 0,
    TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    FinalAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    Status NVARCHAR(20) DEFAULT N'PENDING',     -- PENDING / CONFIRMED / SHIPPING / DONE / CANCELED
    PaymentMethod NVARCHAR(50) NULL,            -- COD / BANK / MOMO / ...
    PaymentStatus NVARCHAR(20) DEFAULT N'UNPAID',  -- UNPAID / PAID / REFUNDED / FAILED
    PaidDate DATETIME NULL,                     -- ngày thanh toán
	FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (VoucherID) REFERENCES Vouchers(VoucherID),
);
-- PaymentMethod	Hình thức thanh toán
--PaymentStatus	Trạng thái thanh toán
--PaidDate	Ngày thanh toán thành công
GO

-- 15. 
CREATE TABLE OrderDetail (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductDetailId INT NOT NULL,              -- Tham chiếu đến ProductDetail (màu + size)
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(12,2) NOT NULL,       -- Giá bán tại thời điểm đặt
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductDetailId) REFERENCES ProductDetail(ProductDetailId)
);
GO


-- 16.
CREATE TABLE Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ShipperName NVARCHAR(100),          -- Tên đơn vị vận chuyển (GHN, GHTK, v.v.)
    TrackingNumber NVARCHAR(50),        -- Mã vận đơn
    ShippedDate DATETIME NULL,          -- Ngày xuất kho
    DeliveredDate DATETIME NULL,        -- Ngày giao hàng thành công
    Status NVARCHAR(20) DEFAULT N'PENDING',  -- PENDING / SHIPPING / DELIVERED / FAILED
    Notes NVARCHAR(255),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO

-- 17.
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    UserID INT NOT NULL,                    -- Người thanh toán
    PaymentMethod NVARCHAR(50) NOT NULL,    -- COD / BANK / MOMO / VNPAY / ...
    Amount DECIMAL(12,2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentStatus NVARCHAR(20) DEFAULT N'PENDING', -- PENDING / SUCCESS / FAILED / REFUNDED
    TransactionCode NVARCHAR(100) NULL,     -- Mã giao dịch từ cổng thanh toán
    Note NVARCHAR(255) NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
	FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE TRIGGER trg_UpdateStockAfterImport
ON ImportDetail
AFTER INSERT
AS
BEGIN
    UPDATE pd
    SET pd.Quantity = pd.Quantity + i.Quantity
    FROM ProductDetail pd
    JOIN inserted i
        ON pd.VersionID = i.VersionID
       AND pd.ColorID = i.ColorID
       AND pd.SizeID = i.SizeID;
END;
