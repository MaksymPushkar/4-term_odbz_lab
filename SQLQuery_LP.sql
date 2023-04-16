USE am_mp_lab;

-- Видалення таблиць
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
    id BIGINT PRIMARY KEY DEFAULT NEXT VALUE FOR commonIncrementForPatient NOT NULL,
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

INSERT INTO patient (firstName, surname, lastName, [address], characteristic) VALUES
	(N'Іван', N'Петров', N'Олександрович', N'м. Київ, вул. Шевченка 1', N'Хронічний бронхіт'),
    (N'Марія', N'Іванова', N'Миколаївна', N'м. Харків, вул. Сумська 10', N'Діабет 2 типу'),
    (N'Олександр', N'Сидоренко', N'Вікторович', N'м. Львів, вул. Зелена 15', N'Гіпертонія'),
    (N'Оксана', N'Ковальчук', N'Олегівна', N'м. Дніпро, вул. Петрова 23', N'Астма'),
    (N'Андрій', N'Білецький', N'Юрійович', N'м. Луцьк, вул. Володимирська 5', N'Депресія'),
    (N'Тетяна', N'Лисенко', N'Іванівна', N'м. Київ, вул. Хрещатик 23', N'Мігрень');

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
	(3, 10),
	(3, 11),
	(4, 6),
	(5, 2),
	(5, 5),
	(5, 6),
	(5, 8),
	(5, 9),
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
	('2022-02-23', '2022-03-01', 1, 1, 5, 75),
	('2022-03-01', NULL, 3, 2, 2, NULL),
	('2022-03-03', '2022-03-08', 7, 5, 4, 90),
	('2022-03-05', NULL, 2, 4, 1, NULL);

INSERT INTO diseaseAccounting_medicine (diseaseAccounting_id, medicine_id) VALUES
	(1, 1),
	(1, 4),
	(2, 1),
	(2, 3),
	(2, 5),
	(3, 6),
	(3, 9),
	(4, 2),
	(4, 10),
	(4, 11),
	(5, 7),
	(5, 8),
	(5, 12);

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