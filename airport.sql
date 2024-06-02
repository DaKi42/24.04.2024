USE master
GO

CREATE DATABASE Airport
GO

USE Airport
GO

CREATE TABLE Flights (
    flight_id INT PRIMARY KEY,
    aircraft_type NVARCHAR(50),
    departure_time DATETIME,
    arrival_time DATETIME,
    duration INT,
    departure_city NVARCHAR(50),
    arrival_city NVARCHAR(50)
);
GO

CREATE TABLE Tickets (
    ticket_id INT PRIMARY KEY,
    flight_id INT,
    class NVARCHAR(10),
    price DECIMAL(10, 2),
    sold BIT,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);
GO

CREATE TABLE Passengers (
    passenger_id INT PRIMARY KEY,
    name NVARCHAR(100),
    ticket_id INT,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);
GO

INSERT INTO Flights VALUES
(1, 'Boeing 737', '2023-04-14 08:00:00', '2023-04-14 11:00:00', 180, 'London', 'Berlin'),
(2, 'Airbus A320', '2023-04-22 10:30:00', '2023-04-22 12:35:00', 165, 'London', 'Paris'),
(3, 'Boeing 777', '2023-04-25 13:00:00', '2023-04-25 18:00:00', 300, 'London', 'New York');
(4, 'Boeing 777', '2023-04-26 12:00:00', '2023-04-26 19:00:00', 300, 'London', 'New York');
GO

INSERT INTO Tickets VALUES
(1, 1, 'Economy', 200.00, 1),
(2, 1, 'Business', 350.00, 0),
(3, 2, 'Economy', 250.00, 1),
(4, 2, 'Business', 500.00, 0),
(5, 3, 'Economy', 300.00, 1),
(6, 3, 'Business', 1000.00, 1);
GO

INSERT INTO Passengers VALUES
(1, 'Illia Bondar', 1),
(2, 'Jane Smith', 3),
(3, 'Michael Johnson', 5),
(4, 'Bob Brown', 6);
GO


-- ��� ����� � ������������ ����� �� ������������ ����

CREATE PROCEDURE GetFlightsToCityOnDate
    @city NVARCHAR(50),
    @date DATETIME
AS
BEGIN
    SELECT * FROM Flights
    WHERE arrival_city = @city AND CAST(departure_time AS DATE) = CAST(@date AS DATE)
    ORDER BY departure_time;
END
GO

EXEC GetFlightsToCityOnDate 'Berlin', '2023-04-14';

-- ������� ���������� � ����� � ���������� ������������� ������
CREATE PROCEDURE GetLongestFlight
AS
BEGIN
    SELECT TOP 1 * FROM Flights ORDER BY duration DESC;
END
GO

EXEC GetLongestFlight;

-- �������� ��� �����, ������������ ������ ������� ��������� ��� ����
CREATE PROCEDURE GetFlightsOverTwoHours
AS
BEGIN
    SELECT * FROM Flights WHERE duration > 120;
END
GO
EXEC GetFlightsOverTwoHours;

-- �������� ���������� ������ � ������ �����
CREATE PROCEDURE GetFlightCountsByCity
AS
BEGIN
    SELECT arrival_city, COUNT(*) AS total_flights
    FROM Flights
    GROUP BY arrival_city;
END
GO

EXEC GetFlightCountsByCity;

-- �������� �����, � ������� �������� ����� �������������� ������
CREATE PROCEDURE GetMostFrequentDestination
AS
BEGIN
    SELECT TOP 1 arrival_city, COUNT(*) AS total_flights
    FROM Flights GROUP BY arrival_city
    ORDER BY total_flights DESC;
END
GO

EXEC GetMostFrequentDestination;

-- ���������� � ���������� ������ � ������ ����� � ����� ���������� ������ �� ������������ �����

CREATE PROCEDURE GetMonthlyFlightStats
    @month INT,
    @year INT
AS
BEGIN
    SELECT arrival_city, COUNT(*) AS total_flights
    FROM Flights
    WHERE MONTH(departure_time) = @month AND YEAR(departure_time) = @year
    GROUP BY arrival_city;

    SELECT COUNT(*) AS total_monthly_flights
    FROM Flights
    WHERE MONTH(departure_time) = @month AND YEAR(departure_time) = @year;
END
GO

EXEC GetMonthlyFlightStats 4, 2023;


-- ������ ������, ���������� �������, �� ������� ���� ��������� ����� � ������ ������

CREATE PROCEDURE GetAvailableBusinessClassFlightsToday
    @startTime DATETIME,
    @endTime DATETIME
AS
BEGIN
    SELECT F.flight_id, F.departure_time
    FROM Flights F
    JOIN Tickets T ON F.flight_id = T.flight_id
    WHERE F.departure_time >= @startTime
      AND F.departure_time < @endTime
      AND T.class = 'Business'
      AND T.sold = 0
    GROUP BY F.flight_id, F.departure_time;
END
GO

EXEC GetAvailableBusinessClassFlightsToday '2023-04-25 00:00:00', '2023-04-26 00:00:00';

-- ���������� � ���������� ��������� ������� �� ��� ����� �� ��������� ���� � �� ����� �����


CREATE PROCEDURE GetSalesInfoOnDate
    @startTime DATETIME,
    @endTime DATETIME
AS
BEGIN
    SELECT COUNT(*) AS tickets_sold, SUM(price) AS total_revenue
    FROM Tickets T
    JOIN Flights F ON T.flight_id = F.flight_id
    WHERE sold = 1 AND F.departure_time >= @startTime AND F.departure_time < @endTime;
END
GO

EXEC GetSalesInfoOnDate '2023-04-25 00:00:00', '2023-04-26 00:00:00';

-- ���������� � ��������������� ������� ������� �� ������������ ����

CREATE PROCEDURE GetPreSaleInfoOnDate
    @startTime DATETIME,
    @endTime DATETIME
AS
BEGIN
    SELECT F.flight_id, COUNT(T.ticket_id) AS tickets_sold
    FROM Flights F
    JOIN Tickets T ON F.flight_id = T.flight_id
    WHERE F.departure_time >= @startTime AND F.departure_time < @endTime AND T.sold = 1
    GROUP BY F.flight_id;
END
GO

EXEC GetPreSaleInfoOnDate '2023-04-25 00:00:00', '2023-04-26 00:00:00';


-- ������� ������ ���� ������ � �������� ���� �������, � ������� ����������� ������ �� ������� ���������
CREATE PROCEDURE GetAllFlightsAndCitiesFromAirport
    @departure_city NVARCHAR(50)
AS
BEGIN
    SELECT DISTINCT flight_id, arrival_city FROM Flights WHERE departure_city = @departure_city;
END
GO

EXEC GetAllFlightsAndCitiesFromAirport 'London';





