-- ============================================================================ 
-- GAMES DATABASE COMPLETE SCRIPT 
-- ============================================================================ 
 
-- ---------------------------------------------------------------------------- 
-- PART 1: SCHEMA CREATION (6 RELATED TABLES WITH PKs & FKs) 
-- ---------------------------------------------------------------------------- 

Create database Gamedb;
use Gamedb;
 
-- 1. Coaches Table 
CREATE TABLE Coaches ( 
    coach_id INT PRIMARY KEY, 
    coach_name VARCHAR(50) NOT NULL, 
    specialization VARCHAR(50) NOT NULL 
); 
 
-- 2. Teams Table 
CREATE TABLE Teams ( 
    team_id INT PRIMARY KEY, 
    team_name VARCHAR(50) NOT NULL, 
    coach_id INT, 
    FOREIGN KEY (coach_id) REFERENCES Coaches(coach_id) ON DELETE SET NULL 
); 
 
-- 3. Players Table 
CREATE TABLE Players ( 
    player_id INT PRIMARY KEY, 
    player_name VARCHAR(50) NOT NULL, 
    age INT NOT NULL, 
    team_id INT, 
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE SET NULL 
); 
 
-- 4. Games Table 
CREATE TABLE Games ( 
    game_id INT PRIMARY KEY, 
    game_name VARCHAR(50) NOT NULL, 
    min_age INT NOT NULL, 
    max_age INT NOT NULL 
); 
 
-- 5. Tournaments Table 
CREATE TABLE Tournaments ( 
    tournament_id INT PRIMARY KEY, 
    tournament_name VARCHAR(50) NOT NULL, 
    location VARCHAR(50) NOT NULL 
); 
 
-- 6. Player Participation & Scores Table (Junction Table) 
CREATE TABLE Player_Participation ( 
    participation_id INT PRIMARY KEY, 
    player_id INT, 
    game_id INT, 
    tournament_id INT, 
    score INT NOT NULL, 
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE, 
    FOREIGN KEY (game_id) REFERENCES Games(game_id) ON DELETE CASCADE, 
    FOREIGN KEY (tournament_id) REFERENCES Tournaments(tournament_id) ON DELETE CASCADE 
); 
 
 
-- ---------------------------------------------------------------------------- 
-- PART 2: SAMPLE DATA INSERTION 
-- ---------------------------------------------------------------------------- 
 
-- Insert Coaches 
INSERT INTO Coaches VALUES  
(1, 'John Miller', 'Basketball'), 
(2, 'Sarah Connor', 'E-Sports'), 
(3, 'David Warner', 'Cricket'); 
 
-- Insert Teams 
INSERT INTO Teams VALUES  
(101, 'Thunderbolts', 1), 
(102, 'Cyber Knights', 2), 
(103, 'Strikers', 3); 
 
-- Insert Players 
INSERT INTO Players VALUES  
(1, 'Alex Smith', 17, 101), 
(2, 'Rahul Sharma', 24, 103), 
(3, 'Elena Rostova', 29, 102), 
(4, 'Michael Jordan', 32, 101), 
(5, 'Sophia Chen', 15, 102), 
(6, 'David Miller', 21, 103), 
(7, 'Emma Watson', 27, 101); 
 
-- Insert Games 
INSERT INTO Games VALUES  
(1, 'Under-18 Chess', 10, 18), 
(2, 'Pro Basketball', 18, 35), 
(3, 'E-Sports Arena', 14, 30); 
 
-- Insert Tournaments 
INSERT INTO Tournaments VALUES  
(501, 'National Championship', 'New York'), 
(502, 'State Sports Meet', 'California'); 
 
-- Insert Player Participation & Scores 
INSERT INTO Player_Participation VALUES  
(1, 1, 1, 501, 85), 
(2, 2, 2, 501, 95), 
(3, 3, 3, 501, 88), 
(4, 4, 2, 501, 99), 
(5, 5, 1, 502, 70), 
(6, 6, 2, 502, 91), 
(7, 7, 3, 502, 82), 
(8, 2, 3, 502, 89), 
(9, 4, 2, 502, 94); 
 
 
-- ---------------------------------------------------------------------------- 
-- PART 3: JOIN OPERATIONS 
-- ---------------------------------------------------------------------------- 
 
-- Query 3.1: INNER JOIN (Full Participation Details across 5 tables) 
SELECT  
    p.player_name, 
    p.age, 
    t.team_name, 
    c.coach_name, 
    g.game_name, 
    tr.tournament_name, 
    pp.score 
FROM Player_Participation pp 
INNER JOIN Players p ON pp.player_id = p.player_id 
INNER JOIN Teams t ON p.team_id = t.team_id 
INNER JOIN Coaches c ON t.coach_id = c.coach_id 
INNER JOIN Games g ON pp.game_id = g.game_id 
INNER JOIN Tournaments tr ON pp.tournament_id = tr.tournament_id; 
 
-- Query 3.2: LEFT JOIN (List all Teams, including those without assigned players) 
SELECT  
    t.team_name, 
    c.coach_name, 
    p.player_name, 
    p.age 
FROM Teams t 
LEFT JOIN Coaches c ON t.coach_id = c.coach_id 
LEFT JOIN Players p ON t.team_id = p.team_id; 
 
 -- =========================================================
-- PART 3A: DML COMMANDS
-- =========================================================

-- UPDATE
UPDATE Players
SET age = 18
WHERE player_id = 1;

SELECT *
FROM Players
WHERE player_id = 1;


-- DELETE
DELETE FROM Players
WHERE player_id = 7;

SELECT *
FROM Players;


-- =========================================================
-- PART 3B: GROUP BY AND HAVING
-- =========================================================

SELECT
    p.player_id,
    p.player_name,
    SUM(pp.score) AS total_score
FROM Players p
JOIN Player_Participation pp
ON p.player_id = pp.player_id
GROUP BY p.player_id, p.player_name
HAVING SUM(pp.score) > 170;
 
-- ---------------------------------------------------------------------------- 
-- PART 4: SET OPERATIONS 
-- ---------------------------------------------------------------------------- 
 
-- Query 4.1: UNION (Players in Tournament 501 OR Tournament 502 without duplicates) 
SELECT p.player_id, p.player_name  
FROM Players p 
JOIN Player_Participation pp ON p.player_id = pp.player_id 
WHERE pp.tournament_id = 501 
UNION 
SELECT p.player_id, p.player_name  
FROM Players p 
JOIN Player_Participation pp ON p.player_id = pp.player_id 
WHERE pp.tournament_id = 502; 
 
-- Query 4.2: INTERSECT Equivalent (Players who participated in BOTH Tournaments 501 and 502) 
SELECT DISTINCT p.player_id, p.player_name  
FROM Players p 
JOIN Player_Participation pp ON p.player_id = pp.player_id 
WHERE pp.tournament_id = 501  
  AND p.player_id IN ( 
      SELECT player_id  
      FROM Player_Participation  
      WHERE tournament_id = 502 
  ); 
 
-- Query 4.3: EXCEPT Equivalent (Players in Tournament 501 BUT NOT in Tournament 502) 
SELECT DISTINCT p.player_id, p.player_name  
FROM Players p 
JOIN Player_Participation pp ON p.player_id = pp.player_id 
WHERE pp.tournament_id = 501  
  AND p.player_id NOT IN ( 
      SELECT player_id  
      FROM Player_Participation  
      WHERE tournament_id = 502 
  ); 
 
 
-- ---------------------------------------------------------------------------- 
-- PART 5: AGE-BASED GAME ELIGIBILITY LOGIC 
-- ---------------------------------------------------------------------------- 
 
SELECT  
    p.player_name, 
    p.age AS player_age, 
    g.game_name, 
    g.min_age, 
    g.max_age, 
    CASE  
        WHEN p.age BETWEEN g.min_age AND g.max_age THEN 'Eligible' 
        ELSE 'Not Eligible' 
    END AS eligibility_status 
FROM Players p 
CROSS JOIN Games g 
ORDER BY p.player_name, g.game_name; 
 
 
-- ---------------------------------------------------------------------------- 
-- PART 6: VIEWS CREATION & SELECTION 
-- ---------------------------------------------------------------------------- 
 
-- View 1: Top 5 Players based on total scores across games 
CREATE VIEW vw_Top5_Players_By_Score AS 
SELECT  
    p.player_id, 
    p.player_name, 
    t.team_name, 
    SUM(pp.score) AS total_score, 
    MAX(pp.score) AS highest_score 
FROM Players p 
JOIN Player_Participation pp ON p.player_id = pp.player_id 
LEFT JOIN Teams t ON p.team_id = t.team_id 
GROUP BY p.player_id, p.player_name, t.team_name 
ORDER BY total_score DESC 
LIMIT 5; 
 
-- View 2: Top 5 Players arranged by highest age first 
CREATE VIEW vw_Top5_Players_By_Age AS 
SELECT  
    p.player_id, 
    p.player_name, 
    p.age, 
    t.team_name 
FROM Players p 
LEFT JOIN Teams t ON p.team_id = t.team_id 
ORDER BY p.age DESC 
LIMIT 5; 
 
-- Verify View 1 Output 
SELECT * FROM vw_Top5_Players_By_Score; 
 
-- Verify View 2 Output 
SELECT * FROM vw_Top5_Players_By_Age; 