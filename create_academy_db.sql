-- ==============================
-- ACADEMY DATABASE: STRUCTURE, SAMPLE DATA, AND ASSIGNMENT QUERIES
-- Adapted for PostgreSQL
-- ==============================

-- ==============================
-- 1. STRUCTURE (create_academy_db.sql)
-- ==============================
DROP TABLE IF EXISTS Assistants, Curators, Deans, Heads, GroupsCurators, GroupsLectures,
    Schedules, Lectures, LectureRooms, Subjects, "Groups", Departments, Faculties, Teachers CASCADE;

-- Teachers
CREATE TABLE Teachers (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR NOT NULL,
    Surname VARCHAR NOT NULL
);

-- Assistants
CREATE TABLE Assistants (
    Id SERIAL PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

-- Curators
CREATE TABLE Curators (
    Id SERIAL PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

-- Deans
CREATE TABLE Deans (
    Id SERIAL PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

-- Heads
CREATE TABLE Heads (
    Id SERIAL PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

-- Faculties
CREATE TABLE Faculties (
    Id SERIAL PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name VARCHAR(100) NOT NULL UNIQUE,
    DeanId INT NOT NULL REFERENCES Deans(Id)
);

-- Departments
CREATE TABLE Departments (
    Id SERIAL PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name VARCHAR(100) NOT NULL UNIQUE,
    FacultyId INT NOT NULL REFERENCES Faculties(Id),
    HeadId INT NOT NULL REFERENCES Heads(Id)
);

-- Groups
CREATE TABLE "Groups" (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL REFERENCES Departments(Id)
);

-- GroupsCurators
CREATE TABLE GroupsCurators (
    Id SERIAL PRIMARY KEY,
    CuratorId INT NOT NULL REFERENCES Curators(Id),
    GroupId INT NOT NULL REFERENCES "Groups"(Id)
);

-- Subjects
CREATE TABLE Subjects (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE
);

-- Lectures
CREATE TABLE Lectures (
    Id SERIAL PRIMARY KEY,
    SubjectId INT NOT NULL REFERENCES Subjects(Id),
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

-- GroupsLectures
CREATE TABLE GroupsLectures (
    Id SERIAL PRIMARY KEY,
    GroupId INT NOT NULL REFERENCES "Groups"(Id),
    LectureId INT NOT NULL REFERENCES Lectures(Id)
);

-- LectureRooms
CREATE TABLE LectureRooms (
    Id SERIAL PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 6),
    Name VARCHAR(10) NOT NULL UNIQUE
);

-- Schedules
CREATE TABLE Schedules (
    Id SERIAL PRIMARY KEY,
    Class INT NOT NULL CHECK (Class BETWEEN 1 AND 8),
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    Week INT NOT NULL CHECK (Week BETWEEN 1 AND 52),
    LectureId INT NOT NULL REFERENCES Lectures(Id),
    LectureRoomId INT NOT NULL REFERENCES LectureRooms(Id)
);

-- ==============================
-- 2. SAMPLE DATA (load_sample_data.sql)
-- ==============================
-- Teachers
INSERT INTO Teachers (Name, Surname) VALUES
  ('Edward','Hopper'),       -- Id=1
  ('Emily','Stone'),         -- Id=2
  ('Alex','Carmack'),        -- Id=3
  ('John','Smith');          -- Id=4

-- Roles
INSERT INTO Deans     (TeacherId) VALUES (1);  -- Deans.Id=1 -> Edward Hopper
INSERT INTO Heads    (TeacherId) VALUES (4), (3); -- Heads.Id=1->John Smith, Id=2->Alex Carmack
INSERT INTO Assistants(TeacherId) VALUES (2);
INSERT INTO Curators (TeacherId) VALUES (2);

-- Faculties
INSERT INTO Faculties (Building, Name, DeanId) VALUES
  (1, 'Computer Science', 1),  -- Id=1
  (2, 'Arts', 2);              -- Id=2

-- Departments
INSERT INTO Departments (Building, Name, FacultyId, HeadId) VALUES
  (1, 'Software Development', 1, 1),  -- Id=1
  (2, 'Mathematics', 2, 2);           -- Id=2

-- Groups
INSERT INTO "Groups" (Name, Year, DepartmentId) VALUES
  ('F505', 5, 1),  -- Id=1
  ('G501', 5, 2);  -- Id=2

-- Subjects
INSERT INTO Subjects (Name) VALUES
  ('Art History'),       -- Id=1
  ('Programming'),       -- Id=2
  ('Linear Algebra');    -- Id=3

-- Lectures
INSERT INTO Lectures (SubjectId, TeacherId) VALUES
  (1, 1),  -- Id=1: Edward Hopper teaches Art History
  (2, 2),  -- Id=2: Emily Stone teaches Programming
  (3, 3),  -- Id=3: Alex Carmack teaches Linear Algebra
  (1, 4);  -- Id=4: John Smith teaches Art History

-- Link lectures to groups
INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
  (1, 2),  -- F505 attends Programming by Emily Stone
  (2, 3),  -- G501 attends Linear Algebra by Alex Carmack
  (1, 1);  -- F505 also attends Art History by Edward Hopper

-- Rooms
INSERT INTO LectureRooms (Building, Name) VALUES
  (1, 'A101'),
  (2, 'B202'),
  (6, 'A311'),
  (6, 'A104');

-- Schedules
INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES
  (1, 1, 1, 1, 1),  -- Edward Hopper, Mon, wk1, cls1, A101
  (2, 2, 1, 2, 2),  -- Emily Stone, Tue, wk1, cls2, B202
  (3, 5, 1, 3, 1),  -- Alex Carmack, Fri, wk1, cls3, A101
  (3, 3, 2, 4, 1),  -- John Smith, Wed, wk2, cls3, A101
  (1, 2, 1, 1, 3),  -- A311 has Art History Tue wk1 cls1
  (2, 4, 1, 2, 4);  -- A104 has Programming Thu wk1 cls2

-- ==============================
-- 3. ASSIGNMENT QUERIES (queries.sql)
-- ==============================

-- 1. Названия аудиторий, в которых читает лекции преподаватель "Edward Hopper".
SELECT DISTINCT lr.Name AS room_name
FROM LectureRooms lr
JOIN Schedules s ON s.LectureRoomId = lr.Id
JOIN Lectures l ON l.Id = s.LectureId
JOIN Teachers t ON t.Id = l.TeacherId
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

-- 2. Фамилии ассистентов, читающих лекции в группе "F505".
SELECT DISTINCT t.Surname
FROM Teachers t
JOIN Assistants a ON a.TeacherId = t.Id
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN "Groups" g ON g.Id = gl.GroupId
WHERE g.Name = 'F505';

-- 3. Дисциплины, которые читает преподаватель "Alex Carmack" для групп 5-го курса.
SELECT DISTINCT sub.Name AS subject_name
FROM Subjects sub
JOIN Lectures l ON l.SubjectId = sub.Id
JOIN Teachers t ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN "Groups" g ON g.Id = gl.GroupId
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;

-- 4. Фамилии преподавателей, которые не читают лекции по понедельникам.
SELECT t.Surname
FROM Teachers t
WHERE NOT EXISTS (
    SELECT 1 FROM Lectures l
    JOIN Schedules s ON s.LectureId = l.Id
    WHERE l.TeacherId = t.Id AND s.DayOfWeek = 1
);

-- 5. Названия аудиторий и корпусы, в которых нет лекций в среду второй недели на третьей паре.
SELECT lr.Building, lr.Name
FROM LectureRooms lr
WHERE NOT EXISTS (
    SELECT 1 FROM Schedules s
    WHERE s.LectureRoomId = lr.Id
      AND s.DayOfWeek = 3 AND s.Week = 2 AND s.Class = 3
);

-- 6. Полные имена преподавателей факультета "Computer Science",
--    которые не курируют группы кафедры "Software Development".
SELECT DISTINCT t.Name || ' ' || t.Surname AS full_name
FROM Teachers t
-- teachers of this faculty via lectures to its groups
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN "Groups" g ON g.Id = gl.GroupId
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
LEFT JOIN GroupsCurators gc ON gc.CuratorId = (
    SELECT c.Id FROM Curators c WHERE c.TeacherId = t.Id
)
WHERE f.Name = 'Computer Science'
  AND NOT EXISTS (
    SELECT 1 FROM GroupsCurators gc2
    JOIN "Groups" g2 ON g2.Id = gc2.GroupId
    JOIN Departments d2 ON d2.Id = g2.DepartmentId
    WHERE gc2.CuratorId = (
        SELECT c2.Id FROM Curators c2 WHERE c2.TeacherId = t.Id
    )
      AND d2.Name = 'Software Development'
);

-- 7. Список номеров корпусов из таблиц факультетов, кафедр и аудиторий.
SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms;

-- 8. Полные имена преподавателей в порядке: деканы, заведующие, преподаватели, кураторы, ассистенты.
SELECT t.Name || ' ' || t.Surname AS full_name, 1 AS ord FROM Teachers t JOIN Deans d ON d.TeacherId = t.Id
UNION ALL
SELECT t.Name || ' ' || t.Surname, 2 FROM Teachers t JOIN Heads h ON h.TeacherId = t.Id
UNION ALL
SELECT t.Name || ' ' || t.Surname, 3 FROM Teachers t
  WHERE t.Id NOT IN (
    SELECT TeacherId FROM Deans
    UNION SELECT TeacherId FROM Heads
    UNION SELECT TeacherId FROM Curators
    UNION SELECT TeacherId FROM Assistants
)
UNION ALL
SELECT t.Name || ' ' || t.Surname, 4 FROM Teachers t JOIN Curators c ON c.TeacherId = t.Id
UNION ALL
SELECT t.Name || ' ' || t.Surname, 5 FROM Teachers t JOIN Assistants a ON a.TeacherId = t.Id
ORDER BY ord;

-- 9. Дни недели (без повторений), в которые имеются занятия в аудиториях "A311" и "A104" корпуса 6.
SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE lr.Name IN ('A311','A104') AND lr.Building = 6;
