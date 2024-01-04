-- Создание таблицы Clients
CREATE TABLE Clients (
    Client_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Contact_Info VARCHAR(100),
    Address VARCHAR(255)
);

-- Создание таблицы Employees
CREATE TABLE Employees (
    Employee_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Position VARCHAR(50),
    Contact_Info VARCHAR(100)
);

-- Создание таблицы Services
CREATE TABLE Services (
    Service_ID INT PRIMARY KEY,
    Service_Name VARCHAR(100),
    Description TEXT,
    Price DECIMAL(10, 2)
);

-- Создание таблицы Orders
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Client_ID INT,
    Employee_ID INT,
    Date DATE,
    Status VARCHAR(50),
    Total_Amount DECIMAL(10, 2),
    Payment_Status VARCHAR(50),
    FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

-- Создание таблицы Order_Services
CREATE TABLE Order_Services (
    Order_ID INT,
    Service_ID INT,
    Quantity INT,
    PRIMARY KEY (Order_ID, Service_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID)
);

-- Создание таблицы Payments
CREATE TABLE Payments (
    Payment_ID INT PRIMARY KEY,
    Order_ID INT,
    Amount DECIMAL(10, 2),
    Payment_Date DATE,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
);

-- INSERT
-- Триггер для связи между таблицами Orders и Clients
CREATE TRIGGER FK_Clients_Orders
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
IF NOT EXISTS (SELECT * FROM Clients WHERE Client_ID = NEW.Client_ID) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client_ID не найдено';
END IF;
END;

-- Триггер для связи между таблицами Orders и Employees
CREATE TRIGGER FK_Employees_Orders
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
IF NOT EXISTS (SELECT * FROM Employees WHERE Employee_ID = NEW.Employee_ID) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee_ID не найдено';
END IF;
END;

-- Триггер для связи между таблицами Order_Services и Orders
CREATE TRIGGER FK_Orders_Order_Services
BEFORE INSERT ON Order_Services
FOR EACH ROW
BEGIN
IF NOT EXISTS (SELECT * FROM Orders WHERE Order_ID = NEW.Order_ID) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order_ID не найдено';
END IF;
END;

-- Триггер для связи между таблицами Order_Services и Services
CREATE TRIGGER FK_Services_Order_Services
BEFORE INSERT ON Order_Services
FOR EACH ROW
BEGIN
IF NOT EXISTS (SELECT * FROM Services WHERE Service_ID = NEW.Service_ID) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Service ID не найдено';
END IF;
END;

-- Триггер для связи между таблицами Payments и Orders
CREATE TRIGGER FK_Orders_Payments
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
IF NOT EXISTS (SELECT * FROM Orders WHERE Order_ID = NEW.Order_ID) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order_ID не найдено';
END IF;
END;

-- UPDATE
-- Триггер "UPDATE" между таблицами Orders и Clients
CREATE TRIGGER FK_Clients_Orders_UPDATE
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
IF NEW.Client_ID NOT IN (SELECT Client_ID FROM Clients) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Недопустимый идентификатор Client_ID";
END IF;
END;

-- Триггер "UPDATE" между таблицами Orders и Employees
CREATE TRIGGER FK_Employees_Orders_UPDATE
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
IF NEW.Employee_ID NOT IN (SELECT Employee_ID FROM Employees) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Недопустимый идентификатор Employee_ID";
END IF;
END;

-- Триггер "UPDATE" между таблицами Orders и Order_Services
CREATE TRIGGER FK_Orders_Order_Services_UPDATE
BEFORE UPDATE ON Order_Services
FOR EACH ROW
BEGIN
IF NEW.Order_ID NOT IN (SELECT Order_ID FROM Orders) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Недопустимый идентификатор Order_ID";
END IF;
END;

-- Триггер "UPDATE" между таблицами Services и Order_Services
CREATE TRIGGER FK_Services_Order_Services_UPDATE
BEFORE UPDATE ON Order_Services
FOR EACH ROW
BEGIN
IF NEW.Service_ID NOT IN (SELECT Service_ID FROM Services) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Недопустимый идентификатор Service_ID";
END IF;
END;

-- Триггер "UPDATE" между таблицами Orders и Payments
CREATE TRIGGER FK_Orders_Payments_UPDATE
BEFORE UPDATE ON Payments
FOR EACH ROW
BEGIN
IF NEW.Order_ID NOT IN (SELECT Order_ID FROM Orders) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Недопустимый идентификатор Order_ID";
END IF;
END;

-- DELETE
-- Триггер для таблицы Clients, запрещающий удаление записи, если на нее есть ссылки в таблице Orders
CREATE TRIGGER FK_Clients_Orders_DELETE
BEFORE DELETE ON Clients
FOR EACH ROW
BEGIN
DECLARE total INT;
SET total = (SELECT COUNT(*) FROM Orders WHERE Client_ID = OLD.Client_ID);
IF total > 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Невозможно удалить запись Client_ID, на нее есть ссылка в таблице Orders';
END IF;
END;

-- Триггер для таблицы Employees, запрещающий удаление записи, если на нее есть ссылки в таблице Orders
CREATE TRIGGER FK_Employees_Orders_DELETE
BEFORE DELETE ON Employees
FOR EACH ROW
BEGIN
DECLARE total INT;
SET total = (SELECT COUNT(*) FROM Orders WHERE Employee_ID = OLD.Employee_ID);
IF total > 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Невозможно удалить запись Employee_ID, на нее есть ссылка в таблице Orders';
END IF;
END;

-- Триггер для таблицы Orders, запрещающий удаление записи, если на нее есть ссылки в таблице Order_Services
CREATE TRIGGER FK_Orders_Order_Services_DELETE
BEFORE DELETE ON Orders
FOR EACH ROW
BEGIN
DECLARE total INT;
SET total = (SELECT COUNT(*) FROM Order_Services WHERE Order_ID = OLD.Order_ID);
IF total > 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Невозможно удалить запись Order_ID, на нее есть ссылка в таблице Order_Services';
END IF;
END;

-- Триггер для таблицы Services, запрещающий удаление записи, если на нее есть ссылки в таблице Order_Services
CREATE TRIGGER FK_Services_Order_Services_DELETE
BEFORE DELETE ON Services
FOR EACH ROW
BEGIN
DECLARE total INT;
SET total = (SELECT COUNT(*) FROM Order_Services WHERE Service_ID = OLD.Service_ID);
IF total > 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Невозможно удалить запись Service_ID, на нее есть ссылка в таблице Order_Services';
END IF;
END;

-- Триггер для таблицы Orders, запрещающий удаление записи, если на нее есть ссылки в таблице Payments
CREATE TRIGGER FK_Orders_Payments_DELETE
BEFORE DELETE ON Orders
FOR EACH ROW
BEGIN
DECLARE total INT;
SET total = (SELECT COUNT(*) FROM Payments WHERE Order_ID = OLD.Order_ID);
IF total > 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Невозможно удалить запись Order_ID, на нее есть ссылка в таблице Payments';
END IF;
END;

-- Вставка данных в таблицу Clients
INSERT INTO Clients (Client_ID, Name, Contact_Info, Address)
VALUES
    (1, 'Алексей Игнатов', 'aleksey.ignatov@email.com', 'пр. Советский, д. 12'),
    (2, 'Надежда Соколова', 'nadezhda.sokolova@email.com', 'ул. Железнодорожная, д. 9'),
    (3, 'Дмитрий Новиков', 'dmitriy.novikov@email.com', 'пр. Центральный, д. 6'),
    (4, 'Анастасия Медведева', 'anastasia.medvedeva@email.com', 'ул. Лесная, д. 8'),
    (5, 'Андрей Соловьев', 'andrey.solovev@email.com', 'пер. Зеленый, д. 13'),
    (6, 'Елена Исаева', 'elena.isaeva@email.com', 'ул. Горького, д. 17'),
    (7, 'Игорь Кузьмин', 'igor.kuzmin@email.com', 'пр. Гагарина, д. 30'),
    (8, 'Марина Морозова', 'marina.morozova@email.com', 'ул. Пролетарская, д. 18'),
    (9, 'Николай Белов', 'nikolay.belov@email.com', 'пер. Садовый, д. 9'),
    (10, 'Екатерина Антонова', 'ekaterina.antonova@email.com', 'ул. Солнечная, д. 5'),
    (11, 'Виктория Романова', 'viktoriya.romanova@email.com', 'пр. Победы, д. 10'),
    (12, 'Александр Миронов', 'aleksandr.mironov@email.com', 'ул. Мира, д. 3'),
    (13, 'Юлия Козлова', 'yuliya.kozlova@email.com', 'пер. Цветочный, д. 12'),
    (14, 'Сергей Смирнов', 'sergey.smirnov@email.com', 'ул. Зеленая, д. 5'),
    (15, 'Маргарита Петрова', 'margarita.petrova@email.com', 'пр. Лесной, д. 18'),
    (16, 'Дмитрий Иванов', 'dmitriy.ivanov@email.com', 'ул. Советская, д. 20'),
    (17, 'Елена Соколова', 'elena.sokolova@email.com', 'пр. Железнодорожный, д. 17'),
    (18, 'Анатолий Новиков', 'anatoliy.novikov@email.com', 'ул. Центральная, д. 10'),
    (19, 'Ольга Медведева', 'olga.medvedeva@email.com', 'пр. Лесной, д. 5'),
    (20, 'Денис Соловьев', 'denis.solovev@email.com', 'ул. Зеленый, д. 13');

-- Вставка данных в таблицу Employees
INSERT INTO Employees (Employee_ID, Name, Position, Contact_Info)
VALUES
    (1, 'Дмитрий Иванов', 'Уборщик', 'dmitriy.ivanov@email.com'),
    (2, 'Алиса Смирнова', 'Менеджер по клинингу', 'alisa.smirnova@email.com'),
    (3, 'Иван Петров', 'Супервайзер', 'ivan.petrov@email.com'),
    (4, 'Екатерина Михайлова', 'Старший уборщик', 'ekaterina.mihaylova@email.com'),
    (5, 'Александр Козлов', 'Администратор клининговой команды', 'alexander.kozlov@email.com'),
    (6, 'Наталья Семенова', 'Координатор клининговых услуг', 'natalya.semenova@email.com'),
    (7, 'Игорь Волков', 'Технический специалист', 'igor.volkov@email.com'),
    (8, 'Елена Николаева', 'Клининговый аналитик', 'elena.nikolaeva@email.com'),
    (9, 'Анна Смирнова', 'Координатор инвентаризации', 'anna.smirnova@email.com'),
    (10, 'Павел Кузнецов', 'Менеджер по обслуживанию клиентов', 'pavel.kuznetsov@email.com'),
    (11, 'Светлана Иванова', 'Уборщица', 'svetlana.ivanova@email.com'),
    (12, 'Андрей Петров', 'Менеджер по клинингу', 'andrey.petrov@email.com'),
    (13, 'Марина Соколова', 'Супервайзер', 'marina.sokolova@email.com'),
    (14, 'Сергей Михайлов', 'Старший уборщик', 'sergey.mihaylov@email.com'),
    (15, 'Евгения Козлова', 'Администратор клининговой команды', 'evgenia.kozlova@email.com'),
    (16, 'Денис Семенов', 'Координатор клининговых услуг', 'denis.semenov@email.com'),
    (17, 'Юлия Волкова', 'Технический специалист', 'yuliya.volkova@email.com'),
    (18, 'Алексей Новиков', 'Клининговый аналитик', 'alexey.novikov@email.com'),
    (19, 'Анастасия Смирнова', 'Координатор инвентаризации', 'anastasiya.smirnova@email.com'),
    (20, 'Максим Кузнецов', 'Менеджер по обслуживанию клиентов', 'maxim.kuznetsov@email.com');

-- Вставка данных в таблицу Services
INSERT INTO Services (Service_ID, Service_Name, Description, Price)
VALUES
    (1, 'Уборка коттеджей', 'Уборка и уход за коттеджными помещениями', 10000.00),
    (2, 'Мойка фасадов зданий', 'Мойка и очистка фасадов зданий', 8000.00),
    (3, 'Уборка школ и детских садов', 'Уборка классов, коридоров и игровых площадок', 6000.00),
    (4, 'Химчистка жалюзи', 'Очистка и обработка жалюзи', 2500.00),
    (5, 'Уборка больниц', 'Уборка палат, коридоров и медицинского оборудования', 7000.00),
    (6, 'Мойка автомобильных ковриков', 'Мойка и чистка ковриков в автомобиле', 1500.00),
    (7, 'Уборка спортивных залов', 'Уборка тренажерных залов и спортивных площадок', 5000.00),
    (8, 'Химчистка матрасов', 'Очистка и обработка матрасов химическим способом', 3000.00),
    (9, 'Уборка кинотеатров', 'Уборка залов и лобби кинотеатров', 5500.00),
    (10, 'Мойка балконов и террас', 'Мойка и очистка балконов и террас', 2000.00),
    (11, 'Уборка салонов красоты', 'Уборка салонов и кабинетов красоты', 4500.00),
    (12, 'Мойка ковровых покрытий', 'Мойка и чистка ковровых покрытий', 3500.00),
    (13, 'Уборка ресторанов быстрого питания', 'Уборка помещений фаст-фуд ресторанов', 4000.00),
    (14, 'Мойка стеклянных поверхностей', 'Мойка и чистка стеклянных поверхностей', 3000.00),
    (15, 'Уборка конференц-залов', 'Уборка конференц-залов и переговорных комнат', 6000.00),
    (16, 'Химчистка кожаной мебели', 'Очистка и обработка кожаной мебели', 4500.00),
    (17, 'Уборка банков', 'Уборка банковских помещений и кассовых залов', 7000.00),
    (18, 'Мойка фасадов магазинов', 'Мойка и очистка фасадов магазинов', 4000.00),
    (19, 'Уборка ресторанов высокой кухни', 'Уборка помещений ресторанов премиум класса', 8000.00),
    (20, 'Мойка автомобилей сухим способом', 'Мойка и чистка автомобилей без использования воды', 3500.00);

-- Вставка данных в таблицу Orders
INSERT INTO Orders (Order_ID, Client_ID, Employee_ID, Date, Status, Total_Amount, Payment_Status)
VALUES
    (1, 1, 1, '2023-11-01', 'В процессе', 3000.00, 'Ожидает оплаты'),
    (2, 2, 2, '2023-12-01', 'Завершен', 1500.00, 'Оплачен'),
    (3, 3, 3, '2023-01-02', 'Ожидает выполнения', 6000.00, 'Не оплачен'),
    (4, 4, 4, '2023-02-02', 'В процессе', 12000.00, 'Ожидает оплаты'),
    (5, 5, 5, '2023-03-02', 'Завершен', 9000.00, 'Оплачен'),
    (6, 6, 6, '2023-04-02', 'В процессе', 11000.00, 'Ожидает оплаты'),
    (7, 7, 7, '2023-05-02', 'Завершен', 7000.00, 'Оплачен'),
    (8, 8, 8, '2023-06-02', 'В процессе', 5000.00, 'Ожидает оплаты'),
    (9, 9, 9, '2023-07-02', 'Ожидает выполнения', 3500.00, 'Не оплачен'),
    (10, 10, 10, '2023-08-02', 'Завершен', 5500.00, 'Оплачен'),
    (11, 11, 11, '2023-09-02', 'В процессе', 4000.00, 'Ожидает оплаты'),
    (12, 12, 12, '2023-10-02', 'Ожидает выполнения', 2000.00, 'Не оплачен'),
    (13, 13, 13, '2023-11-02', 'В процессе', 8000.00, 'Ожидает оплаты'),
    (14, 14, 14, '2023-12-02', 'Завершен', 3000.00, 'Оплачен'),
    (15, 15, 15, '2023-01-03', 'Ожидает выполнения', 5000.00, 'Не оплачен'),
    (16, 16, 16, '2023-02-03', 'В процессе', 10000.00, 'Ожидает оплаты'),
    (17, 17, 17, '2023-03-03', 'Завершен', 7000.00, 'Оплачен'),
    (18, 18, 18, '2023-04-03', 'В процессе', 6000.00, 'Ожидает оплаты'),
    (19, 19, 19, '2023-05-03', 'Завершен', 4000.00, 'Оплачен'),
    (20, 20, 20, '2023-06-03', 'В процессе', 2000.00, 'Ожидает оплаты');

-- Вставка данных в таблицу Order_Services
INSERT INTO Order_Services (Order_ID, Service_ID, Quantity)
VALUES
    (7, 8, 2),
    (9, 12, 1),
    (11, 14, 3),
    (13, 16, 2),
    (15, 18, 1),
    (17, 20, 2),
    (19, 2, 3),
    (8, 6, 2),
    (16, 10, 1),
    (18, 4, 3),
    (20, 1, 2),
    (7, 5, 2),
    (9, 3, 1),
    (11, 7, 3),
    (13, 9, 2),
    (15, 11, 1),
    (17, 13, 2),
    (19, 15, 3),
    (8, 17, 2),
    (16, 19, 1);

-- Вставка данных в таблицу Payments
INSERT INTO Payments (Payment_ID, Order_ID, Amount, Payment_Date)
VALUES
    (1, 11, 900.00, '2023-01-15'),
    (2, 12, 500.00, '2023-02-20'),
    (3, 13, 800.00, '2023-03-25'),
    (4, 14, 1200.00, '2023-04-29'),
    (5, 15, 700.00, '2023-05-05'),
    (6, 16, 1000.00, '2023-06-10'),
    (7, 17, 600.00, '2023-07-15'),
    (8, 18, 400.00, '2023-08-20'),
    (9, 19, 250.00, '2023-09-25'),
    (10, 20, 1500.00, '2023-10-30'),
    (11, 1, 700.00, '2023-11-05'),
    (12, 2, 300.00, '2023-12-10'),
    (13, 3, 700.00, '2023-12-15'),
    (14, 4, 1000.00, '2023-12-20'),
    (15, 5, 800.00, '2023-12-25'),
    (16, 6, 1200.00, '2023-12-30'),
    (17, 7, 600.00, '2023-12-31'),
    (18, 8, 400.00, '2023-12-31'),
    (19, 9, 250.00, '2023-12-31'),
    (20, 10, 1500.00, '2023-12-31');

-- Вывод данных из таблицы Clients
SELECT * FROM Clients;