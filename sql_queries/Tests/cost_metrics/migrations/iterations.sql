DROP TABLE IF EXISTS #Employees;
CREATE TABLE #Employees (
    crmid                       INT,
    scid                        INT,
    name                        VARCHAR(20),
    year_month                  DATE,
    position_id                 INT,
    chapter_id                  INT,
    has_support_processing_role BIT
)

DROP TABLE IF EXISTS #IterationsRaw;
CREATE TABLE #IterationsRaw (
    emp_scid    INT,
    year_month  DATE,
    ticket_scid INT,
    post_id     INT
)

DROP TABLE IF EXISTS #SCWorkHours;
CREATE TABLE #SCWorkHours (
    emp_scid    INT,
    year_month  DATE,
    work_hours  FLOAT
)

INSERT INTO #Employees
VALUES  (1, 1, 'emp1', '2023-11-01', 1, 1, 0),
        (1, 1, 'emp1', '2023-12-01', 1, 1, 0),
        (1, 1, 'emp1', '2024-01-01', 1, 1, 0)

INSERT INTO #IterationsRaw
VALUES  (1, '2023-10-01', 1, 0),
        (1, '2023-10-01', 1, 2),
        (1, '2023-11-01', 2, 0),
        (1, '2023-11-01', 2, 2),
        (1, '2023-12-01', 3, 0),
        (1, '2023-12-01', 3, 1),
        (1, '2023-12-01', 4, 0),
        (1, '2024-01-01', 4, 1),
        (1, '2024-01-01', 5, 2),
        (1, '2024-01-01', 6, 0),
        (1, '2024-01-01', 6, 1)

INSERT INTO #SCWorkHours
VALUES  (1, '2023-12-01', 150.75),
        (1, '2024-01-01', 155)

