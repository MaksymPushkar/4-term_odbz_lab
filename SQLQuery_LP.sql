USE am_mp_lab;

GO

IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = N'Василь_Логін'
)
BEGIN
    DROP LOGIN [Василь_Логін];
END;
IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = N'Назар_Логін'
)
BEGIN
    DROP LOGIN [Назар_Логін];
END;
IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = N'Вікторія_Логін'
)
BEGIN
    DROP LOGIN [Вікторія_Логін];
END;

IF EXISTS (
    SELECT 1
    FROM sys.sysusers
    WHERE name = N'Василь_Юзер'
)
BEGIN
    DROP USER [Василь_Юзер];
END;
IF EXISTS (
    SELECT 1
    FROM sys.sysusers
    WHERE name = N'Назар_Юзер'
)
BEGIN
    DROP USER [Назар_Юзер];
END;
IF EXISTS (
    SELECT 1
    FROM sys.sysusers
    WHERE name = N'Вікторія_Юзер'
)
BEGIN
    DROP USER [Вікторія_Юзер];
END;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'Лікар' AND type = 'R')
BEGIN
    DROP ROLE [Лікар];
END
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'HR_менеджер' AND type = 'R')
BEGIN
    DROP ROLE [HR_менеджер];
END

CREATE LOGIN [Василь_Логін] WITH PASSWORD = '123';
CREATE LOGIN [Назар_Логін] WITH PASSWORD = '456';
CREATE LOGIN [Вікторія_Логін] WITH PASSWORD = '789';

CREATE USER [Василь_Юзер] FOR LOGIN [Василь_Логін];
CREATE USER [Назар_Юзер] FOR LOGIN [Назар_Логін];
CREATE USER [Вікторія_Юзер] FOR LOGIN [Вікторія_Логін];

CREATE ROLE [Лікар];
CREATE ROLE [HR_менеджер];

SELECT *
FROM sys.server_principals
WHERE name = N'Василь_Логін';

SELECT name, type_desc
FROM sys.server_principals
WHERE type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN'); -- Фільтр для вибору тільки логінів

SELECT name, type_desc
FROM sys.database_principals
WHERE type_desc IN ('SQL_USER', 'WINDOWS_USER'); -- Фільтр для вибору тільки користувачів

SELECT u.name AS username, r.name AS rolename
FROM sys.database_role_members m
JOIN sys.database_principals u ON m.member_principal_id = u.principal_id
JOIN sys.database_principals r ON m.role_principal_id = r.principal_id

-- Видалення процедури
IF OBJECT_ID('calculateDoctorRatings', 'P') IS NOT NULL 
    DROP PROCEDURE calculateDoctorRatings;

-- Видалення таблиць
IF OBJECT_ID('doctorRatings', 'U') IS NOT NULL
    DROP TABLE doctorRatings;
IF OBJECT_ID('diseaseAccounting_medicine', 'U') IS NOT NULL
    DROP TABLE diseaseAccounting_medicine;
IF OBJECT_ID('diseaseAccounting', 'U') IS NOT NULL
    DROP TABLE diseaseAccounting;
IF OBJECT_ID('patientContraindication', 'U') IS NOT NULL
    DROP TABLE patientContraindication;
IF OBJECT_ID('disease_symptom', 'U') IS NOT NULL
    DROP TABLE disease_symptom;
IF OBJECT_ID('medicine_component', 'U') IS NOT NULL
    DROP TABLE medicine_component;
IF OBJECT_ID('doctor', 'U') IS NOT NULL
    DROP TABLE doctor;
IF OBJECT_ID('patient', 'U') IS NOT NULL
    DROP TABLE patient;
IF OBJECT_ID('disease', 'U') IS NOT NULL
    DROP TABLE disease;
IF OBJECT_ID('symptom', 'U') IS NOT NULL
    DROP TABLE symptom;
IF OBJECT_ID('medicine', 'U') IS NOT NULL
    DROP TABLE medicine;
IF OBJECT_ID('component', 'U') IS NOT NULL
    DROP TABLE component;

-- Видалення послідовності
IF EXISTS (SELECT * FROM sys.sequences WHERE name = 'commonIncrementForPatient')
    DROP SEQUENCE commonIncrementForPatient;


-- Створення послідовності та видалення попередньої за наявності
CREATE SEQUENCE commonIncrementForPatient
	START WITH 1
	INCREMENT BY 1
	NO CYCLE;

-- Створення таблиць
CREATE TABLE component (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
    [name] NVARCHAR(50) NOT NULL
);

CREATE TABLE medicine (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	[name] NVARCHAR(50) NOT NULL
);

CREATE TABLE symptom (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	[name] NVARCHAR(50) NOT NULL
);

CREATE TABLE disease (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	[name] NVARCHAR(50) NOT NULL
);

CREATE TABLE patient (
    id BIGINT PRIMARY KEY NOT NULL,
    firstName NVARCHAR(50) NOT NULL,
    surname NVARCHAR(50) NOT NULL,
    lastName NVARCHAR(50) NOT NULL,
    [address] NVARCHAR(50) NOT NULL,
    characteristic NVARCHAR(50) NOT NULL
);

CREATE TABLE doctor (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	lastname NVARCHAR(50) NOT NULL,
	spatialization NVARCHAR(50) NOT NULL,
	[address] NVARCHAR(50) NOT NULL
);

CREATE TABLE medicine_component (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	medicine_id BIGINT FOREIGN KEY REFERENCES medicine(id) ON DELETE CASCADE NOT NULL,
	component_id BIGINT FOREIGN KEY REFERENCES component(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE patientContraindication (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
    patient_id BIGINT FOREIGN KEY REFERENCES patient(id) ON DELETE CASCADE NOT NULL,
    component_id BIGINT FOREIGN KEY REFERENCES component(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE disease_symptom (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
    disease_id BIGINT FOREIGN KEY REFERENCES disease(id) ON DELETE CASCADE NOT NULL,
    symptom_id BIGINT FOREIGN KEY REFERENCES symptom(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE diseaseAccounting (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	[start] DATE NOT NULL,
	[end] DATE,
	disease_id BIGINT FOREIGN KEY REFERENCES disease(id) ON DELETE CASCADE NOT NULL,
	patient_id BIGINT FOREIGN KEY REFERENCES patient(id) ON DELETE CASCADE NOT NULL,
	doctor_id BIGINT FOREIGN KEY REFERENCES doctor(id) ON DELETE CASCADE NOT NULL,
	effectivity TINYINT CHECK(effectivity >= 0 AND effectivity <= 100)
);

CREATE TABLE diseaseAccounting_medicine (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
    diseaseAccounting_id BIGINT FOREIGN KEY REFERENCES diseaseAccounting(id) ON DELETE CASCADE NOT NULL,
    medicine_id BIGINT FOREIGN KEY REFERENCES medicine(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE doctorRatings (
    id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	doctor_id BIGINT FOREIGN KEY REFERENCES doctor(id) ON DELETE CASCADE NOT NULL,
	rating TINYINT
);

-- Додавання полів UCR, DCR, ULC, DLC до кожної таблиці
ALTER TABLE component ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE medicine ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
ALTER TABLE symptom ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE disease ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE patient ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE doctor ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE medicine_component ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE patientContraindication ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE disease_symptom ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE diseaseAccounting ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE diseaseAccounting_medicine ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;
--ALTER TABLE doctorRatings ADD UCR NVARCHAR(50), DCR DATETIME, ULC NVARCHAR(50), DLC DATETIME;

GO

-- Тригер для заповнення полів UCR, DCR, ULC, DLC при створенні нового запису в тіблиці component
CREATE TRIGGER setdiseaseAccounting_effectivity
ON diseaseAccounting
AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT i.id
		FROM inserted i
		WHERE i.[end] IS NULL AND i.effectivity IS NOT NULL
	)
	BEGIN
		RAISERROR (N'Не можна оцінювати ефективність, поки не закінчилось лікування!', 16, 1)

		ROLLBACK TRANSACTION
	END
END;

GO

-- Тригер для заповнення полів UCR, DCR, ULC, DLC при створенні нового запису в тіблиці component
CREATE TRIGGER setCreatedFields_component
ON component
AFTER INSERT
AS
BEGIN
    DECLARE @username NVARCHAR(50) = SUSER_SNAME(); -- Ім'я поточного користувача
    DECLARE @currentDateTime DATETIME = GETDATE(); -- Поточна дата та час
	
    UPDATE component
    SET UCR = @username, DCR = @currentDateTime, ULC = @username, DLC = @currentDateTime
    WHERE id IN (SELECT id FROM inserted);
END;

GO

-- Тригер для заповнення полів UCR, DCR, ULC, DLC при створенні нового запису в тіблиці symptom
CREATE TRIGGER setCreatedFields_symptom
ON symptom
AFTER INSERT
AS
BEGIN
    DECLARE @username NVARCHAR(50) = SUSER_SNAME(); -- Ім'я поточного користувача
    DECLARE @currentDateTime DATETIME = GETDATE(); -- Поточна дата та час
	
    UPDATE symptom
    SET UCR = @username, DCR = @currentDateTime, ULC = @username, DLC = @currentDateTime
    WHERE id IN (SELECT id FROM inserted);
END;

GO

CREATE TRIGGER FillSequenceValue
ON patient
INSTEAD OF INSERT
AS
BEGIN
    -- Вставка даних у таблицю з заповненням поля id згідно зі значеннями з послідовності
    INSERT INTO patient (id, firstName, surname, lastName, [address], characteristic)
    SELECT id, firstName, surname, lastName, [address], characteristic
    FROM inserted;

    -- Оновлення поля id згідно зі значеннями з послідовності
    UPDATE p
    SET p.id = s.nextValue
    FROM patient p
    INNER JOIN (
        SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS nextValue
        FROM patient
    ) s ON p.id = s.id;
END;


GO

-- Тригер для перевірки на додавання лікарства з протипоказаною складовою
CREATE TRIGGER checkPatientContraindication
ON diseaseAccounting_medicine
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT pC.id
		FROM inserted i
		INNER JOIN diseaseAccounting dA ON dA.id = i.diseaseAccounting_id
		INNER JOIN patientContraindication pC ON pC.patient_id = dA.patient_id
		INNER JOIN medicine_component mc ON mc.component_id = pC.component_id
		WHERE i.medicine_id = mc.medicine_id
    )
    BEGIN
		DECLARE @patient_name NVARCHAR(50), @contraindication NVARCHAR(50), @medicine NVARCHAR(50);

	    SELECT @patient_name = dA.patient_id, @contraindication = pC.component_id, @medicine = i.medicine_id
		FROM inserted i
		INNER JOIN diseaseAccounting dA ON dA.id = i.diseaseAccounting_id
		INNER JOIN patientContraindication pC ON pC.patient_id = dA.patient_id
		INNER JOIN medicine_component mc ON mc.component_id = pC.component_id
		WHERE i.medicine_id = mc.medicine_id;

		DECLARE @error_message NVARCHAR(200) = CONCAT(N'Пацієнт з id:', @patient_name, N' має протипоказання до компонета з id:', @contraindication, N' що є у лікарстві з id:', @medicine, N'!');

        RAISERROR (@error_message, 16, 1);

        ROLLBACK TRANSACTION;
    END
END;

GO

--Тригер для перевірки додавання лікаря до облкіку хвороб
CREATE TRIGGER checkDoctorPatientCount
ON diseaseAccounting
AFTER INSERT
AS
BEGIN
	IF EXISTS (
		SELECT dA.doctor_id AS patientCount FROM diseaseAccounting dA
		GROUP BY dA.doctor_id
		HAVING COUNT(dA.patient_id) >= 10
	)
	BEGIN
		DECLARE @doctor_name NVARCHAR(50);

		SELECT @doctor_name = dA.doctor_id FROM diseaseAccounting dA
		GROUP BY dA.doctor_id
		HAVING COUNT(dA.patient_id) >= 10;

		DECLARE @error_message NVARCHAR(200) = CONCAT(N'Лікар з id:', @doctor_name, ' вже має одночасно 10 пацієнтів!');

        RAISERROR (@error_message, 16, 1);

        ROLLBACK TRANSACTION;
	END
END
GO

-- Наповнення таблиць
INSERT INTO component ([name]) VALUES
	(N'Ацетилсаліцилова кислота'),
	(N'Амоксицилін'),
	(N'Ампіцилін'),
	(N'Глюкозамін'),
	(N'Ібупрофен'),
	(N'Кодеїн'),
	(N'Кофеїн'),
	(N'Метформін'),
	(N'Парацетамол'),
	(N'Тетрациклін'),
	(N'Фенобарбітал'),
	(N'Феноксиметилпеніцилін'),
	(N'Фентанил'),
	(N'Флебодіа');

INSERT INTO medicine ([name]) VALUES
	(N'Парацетамол'),
	(N'Дексаметазон'),
	(N'Амброксол'),
	(N'Аспірин'),
	(N'Лоратадин'),
	(N'Нізка кислотність'),
	(N'Піроглав'),
	(N'Ацикловір'),
	(N'Азитроміцин'),
	(N'Ібупрофен'),
	(N'Левоміцетин'),
	(N'Антигістаміни');

INSERT INTO symptom ([name]) VALUES
    (N'Біль'),
    (N'Кашель'),
    (N'Температура'),
    (N'Нежить'),
    (N'Застуда'),
    (N'Тиск'),
    (N'Біль в горлі'),
    (N'Розлад шлунково-кишкового тракту'),
    (N'Головний біль'),
    (N'Нудота'),
    (N'Запаморочення'),
    (N'Затруднення дихання'),
    (N'Сухість в роті'),
    (N'Зневоднення'),
    (N'Печія');

INSERT INTO disease ([name]) VALUES
    (N'Грип'),
    (N'Пневмонія'),
    (N'Гострий бронхіт'),
    (N'Ангіна'),
    (N'Шлунково-кишкова інфекція'),
    (N'Гастрит'),
    (N'Коронавірусна інфекція'),
    (N'ОРВІ'),
    (N'ОРЗ'),
    (N'Туберкульоз');

INSERT INTO patient (id, firstName, surname, lastName, [address], characteristic) VALUES
	(1, N'Іван', N'Петров', N'Олександрович', N'м. Київ, вул. Шевченка 1', N'Хронічний бронхіт'),
    (5656, N'Марія', N'Іванова', N'Миколаївна', N'м. Харків, вул. Сумська 10', N'Діабет 2 типу'),
    (3, N'Олександр', N'Сидоренко', N'Вікторович', N'м. Львів, вул. Зелена 15', N'Гіпертонія'),
    (566556, N'Оксана', N'Ковальчук', N'Олегівна', N'м. Дніпро, вул. Петрова 23', N'Астма'),
    (5, N'Андрій', N'Білецький', N'Юрійович', N'м. Луцьк, вул. Володимирська 5', N'Депресія'),
    (6, N'Тетяна', N'Лисенко', N'Іванівна', N'м. Київ, вул. Хрещатик 23', N'Мігрень');

INSERT INTO doctor (lastname, spatialization, [address]) VALUES 
    (N'Іваненко', N'Офтальмолог', N'Київ, вул. Хрещатик, 1'),
    (N'Петренко', N'Терапевт', N'Львів, вул. Личаківська, 24'),
    (N'Сидоренко', N'Педіатр', N'Одеса, вул. Дерибасівська, 5'),
    (N'Ковальчук', N'Стоматолог', N'Харків, просп. Незалежності, 2'),
    (N'Мельник', N'Хірург', N'Дніпро, вул. Героїв Сталінграда, 12');

INSERT INTO medicine_component (medicine_id, component_id) VALUES
	(1, 9),
	(2, 2),
	(2, 11),
	(3, 4),
	(3, 6),
	(5, 12),
	(6, 1),
	(6, 8),
	(7, 13),
	(7, 14),
	(8, 8),
	(9, 1),
	(9, 10),
	(10, 5),
	(11, 6),
	(11, 10),
	(12, 2);

INSERT INTO patientContraindication (patient_id, component_id) VALUES
	(1, 6),
	(1, 1),
	--(3, 10),
	(3, 11),
	(4, 6),
	--(5, 2),
	(5, 5),
	(5, 6),
	--(5, 8),
	--(5, 9),
	(5, 11),
	(6, 12);

INSERT INTO disease_symptom (disease_id, symptom_id) VALUES
	(1, 2),
	(1, 3),
	(1, 4),
	(1, 5),
	(1, 7),
	(1, 8),
	(1, 9),
	(2, 2),
	(2, 3),
	(2, 4),
	(2, 5),
	(2, 7),
	(2, 8),
	(2, 9),
	(3, 2),
	(3, 3),
	(3, 4),
	(3, 5),
	(3, 7),
	(3, 8),
	(3, 9),
	(4, 1),
	(4, 3),
	(4, 5),
	(4, 7),
	(4, 8),
	(5, 1),
	(5, 3),
	(5, 5),
	(5, 7),
	(5, 8),
	(6, 7),
	(6, 8),
	(6, 9),
	(7, 2),
	(7, 3),
	(7, 4),
	(7, 5),
	(7, 7),
	(7, 8),
	(7, 9),
	(8, 2),
	(8, 3),
	(8, 4),
	(8, 5),
	(8, 7),
	(8, 8),
	(8, 9),
	(9, 1),
	(9, 2),
	(10, 1),
	(10, 11),
	(10, 13),
	(10, 14),
	(10, 15);

INSERT INTO diseaseAccounting ([start], [end], disease_id, patient_id, doctor_id, effectivity) VALUES
	('2022-02-20', '2022-03-05', 9, 3, 2, 85),
	('2022-02-23', '2022-03-01', 1, 5, 5, 75),
	--('2022-02-24', NULL, 6, 3, 5, NULL),
	--('2022-02-24', NULL, 6, 3, 5, 75),
	('2022-02-25', '2022-03-03', 3, 4, 5, 71),
	('2022-02-26', '2022-03-04', 1, 5, 5, 72),
	('2022-02-27', '2022-03-05', 5, 2, 5, 75),
	('2022-02-28', '2022-03-06', 6, 3, 5, 76),
	('2022-02-25', '2022-03-03', 3, 4, 5, 71),
	('2022-02-26', '2022-03-04', 1, 5, 5, 72),
	('2022-02-27', '2022-03-05', 5, 2, 5, 75),
	--('2022-02-28', '2022-03-06', 6, 3, 5, 76),
	--('2022-02-25', '2022-03-03', 3, 4, 5, 71),
	('2022-03-01', NULL, 3, 2, 2, NULL),
	('2022-03-03', '2022-03-08', 7, 5, 4, 100),
	('2022-03-05', NULL, 2, 4, 1, NULL);

INSERT INTO diseaseAccounting_medicine (diseaseAccounting_id, medicine_id) VALUES
	(1, 1),
	(1, 4),
	(2, 1),
	--(2, 3),
	(2, 5),
	(3, 6),
	(3, 9),
	--(4, 2),
	--(4, 10),
	--(4, 11),
	(5, 7),
	(5, 8),
	(5, 12);

-- Випадково вибираєм кому присвоїти нову характеристику
UPDATE patient SET characteristic = 'Обожнює дивитись А4' WHERE id IN (
    SELECT TOP 1 id FROM patient ORDER BY NEWID()
);

-- Виведення таблиць
SELECT * FROM component;

SELECT * FROM symptom;

SELECT m.*, c.[name] AS component
FROM medicine m
LEFT JOIN medicine_component mc ON m.id = mc.medicine_id
LEFT JOIN component c ON mc.component_id = c.id;

SELECT d.*, s.[name] AS symptom
FROM disease d
LEFT JOIN disease_symptom ds ON d.id = ds.disease_id
LEFT JOIN symptom s ON ds.symptom_id = s.id;

SELECT p.*, c.[name] AS contraindication
FROM patient p
LEFT JOIN patientContraindication pc ON p.id = pc.patient_id
LEFT JOIN component c ON pc.component_id = c.id;

SELECT * FROM doctor;

SELECT
	dA.id,
	dA.[start],
	dA.[end],
	d.[name] AS disease,
	p.firstName AS patientFirstName,
	p.lastName AS patientLastName,
	doc.lastname AS doctorLastname,
	doc.spatialization AS doctorSpatialization,
	m.[name] AS medicine,
	dA.effectivity
FROM diseaseAccounting dA
LEFT JOIN disease d ON dA.disease_id = d.id
LEFT JOIN patient p ON dA.patient_id = p.id
LEFT JOIN doctor doc ON dA.doctor_id = doc.id
LEFT JOIN diseaseAccounting_medicine dAm ON dA.id = dAm.diseaseAccounting_id
LEFT JOIN medicine m ON dAm.medicine_id = m.id;

GO

-- Створення процедури
CREATE PROCEDURE calculateDoctorRatings
AS
BEGIN
  DECLARE @doctor_id BIGINT,
		  @totalPatients INT,
		  @totalTreatmentDuration INT,
		  @totalContraindications INT,
		  @totalEffectivity INT,
		  @doctorRating FLOAT

  -- Цикл для перебору всіх лікарів
  DECLARE doctor_cursor CURSOR FOR
    SELECT id FROM doctor

  OPEN doctor_cursor

  FETCH NEXT FROM doctor_cursor INTO @doctor_id

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Кількість хворих, лікуваних кожним лікарем
    SELECT @totalPatients = COUNT(*) FROM diseaseAccounting WHERE doctor_id = @doctor_id

    -- Загальна тривалість лікування всіх хворих кожним лікарем
    SELECT @totalTreatmentDuration = SUM(DATEDIFF(day, [start], [end])) FROM diseaseAccounting WHERE doctor_id = @doctor_id AND [end] IS NOT NULL

    -- Кількість протипоказань, виявлених у всіх хворих, лікуваних кожним лікарем
    SELECT @totalContraindications = COUNT(*) FROM patientContraindication WHERE patient_id IN (SELECT patient_id FROM diseaseAccounting WHERE doctor_id = @doctor_id)

    -- Загальна ефективність лікування всіх хворих кожним лікарем
    SELECT @totalEffectivity = SUM(effectivity) FROM diseaseAccounting WHERE doctor_id = @doctor_id AND [end] IS NOT NULL

    -- Обраховуємо рейтинг лікаря на основі визначених факторів
    SET @doctorRating = (@totalPatients / 10) + (@totalTreatmentDuration / 30) + ((100 - @totalContraindications) / 10) + (@totalEffectivity / @totalPatients)

    -- Вставляємо рейтинг лікаря в таблицю doctorRatings
    INSERT INTO doctorRatings (doctor_id, rating) VALUES (@doctor_id, @doctorRating)

    FETCH NEXT FROM doctor_cursor INTO @doctor_id
  END

  CLOSE doctor_cursor
  DEALLOCATE doctor_cursor
END

GO

EXEC calculateDoctorRatings;

SELECT
	dr.id,
	d.lastname,  
	dr.rating
FROM doctorRatings dR
LEFT JOIN doctor d ON dR.doctor_id = d.id
ORDER BY dr.rating DESC;


GRANT SELECT, INSERT, UPDATE, DELETE ON patient TO [Лікар];
GRANT SELECT, INSERT, UPDATE, DELETE ON diseaseAccounting TO [Лікар];
GRANT SELECT, INSERT, UPDATE, DELETE ON diseaseAccounting_medicine TO [Лікар];

EXEC sp_addrolemember [HR_менеджер], [Василь_Юзер];
EXEC sp_addrolemember [Лікар], [Назар_Юзер];
EXEC sp_addrolemember [Лікар], [Вікторія_Юзер];

GRANT SELECT, INSERT, UPDATE, DELETE ON doctor TO [HR_менеджер];

REVOKE SELECT, INSERT, UPDATE, DELETE
ON patient
FROM [Вікторія_Юзер];
