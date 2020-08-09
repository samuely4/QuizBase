DROP DATABASE if exists quizbase;
CREATE DATABASE quizbase;

USE quizbase;

-- creating user
CREATE TABLE school(
  schoolId INT AUTO_INCREMENT PRIMARY KEY,
  schoolName VARCHAR(255),
  location VARCHAR(500)
);

CREATE TABLE topic(
  topicId INT AUTO_INCREMENT PRIMARY KEY,
  topicName VARCHAR(255) NOT NULL
);

CREATE TABLE user(
  userId INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL
);

CREATE TABLE class(
  classId INT PRIMARY KEY AUTO_INCREMENT,
  ownerId INT,
  name VARCHAR(255),
  topicId INT,
  description VARCHAR(1000),
  FOREIGN KEY(topicId) REFERENCES topic(topicId),
  FOREIGN KEY(ownerId) REFERENCES user(userId)
);

CREATE TABLE deck(
  deckId INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  classId INT, -- For class decks
  userId INT, -- For user decks
  topicId INT DEFAULT 8,
  creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  schoolId INT,
  foreign key(userId) references user(userId),
  foreign key(classId) references class(classId),
  foreign key(topicId) references topic(topicId),
  foreign key(schoolId) references school(schoolId)
);

CREATE TABLE cards(
  cardId INT PRIMARY KEY AUTO_INCREMENT,
  deckId INT,
  cardName VARCHAR(255),
  description VARCHAR(2000),
  FOREIGN KEY(deckId) REFERENCES deck(deckId)
);

delimiter //
create procedure mergeDecks(IN userID int, IN DnameSrc varchar(255), IN DnameDst varchar(255))
mergeDecksLabel: Begin
	DECLARE deckID1, deckID2 INTEGER UNSIGNED;
    DECLARE topicID1, topicID2 integer unsigned;
    select deckId from deck where userId = userID AND name = DnameSrc LIMIT 1 into deckID1;
    select deckId from deck where userId = userID AND name = DnameDst LIMIT 1 into deckID2;
    select topicId from deck where userId = userID AND deckId = deckID1 into topicID1;
    select topicId from deck where userId = userID AND deckId = deckID2 into topicID2;
    if (topicID1 = topicID2) then
		CALL adjustDecks(userID, deckID1, deckID2);
        ELSE leave mergeDeckslabel;
	End if;
End;//

create procedure adjustDecks(IN userID int, IN Decksrc int, IN Deckdst int)
Begin
	update cards set deckId = Deckdst where deckId = Decksrc;
    delete from deck where userId = userID AND deckId = Decksrc;
End;//

-- CALL mergeDecks(1, 'Linear Algebra 346', 'Algortihms');
-- CALL mergeDecks(1, 'American Revolution', 'Constitution');

CREATE TABLE profile(
  userId INT,
  deckId INT,
  FOREIGN KEY(userId) REFERENCES user(userId),
  FOREIGN KEY(deckId) REFERENCES deck(deckId) ON DELETE CASCADE ON UPDATE CASCADE
);//

CREATE TABLE members(
  userId INT,
  classId INT,
  FOREIGN KEY(userId) REFERENCES user(userId),
  FOREIGN KEY(classId) REFERENCES class(classId)
);//

CREATE TABLE request(
  userId INT,
  classId INT,
  FOREIGN KEY(userId) REFERENCES user(userId),
  FOREIGN KEY(classId) REFERENCES class(classId)
);//

create table userlog(
	ID int auto_increment Primary key,
    userId int NOT NULL,
	username VARCHAR(255) NOT NULL,
    action varchar(255) NOT NULL,
    timeSTP TIMESTAMP Default current_timestamp
);//

delimiter //
create trigger userTRIGUPD
AFTER UPDATE on user
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AudituserUPD(NEW.userId, NEW.username);
END;//

delimiter //
create trigger userTRIGINS
AFTER insert on user
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AudituserINS(NEW.userId, NEW.username);
END;//

delimiter //
create trigger userTRIGDEL
before delete on user
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AudituserDEL(old.userId, old.username);
END;//

delimiter //
create function AudituserUPD(param2 int, param3 varchar(255)) returns int
Deterministic
begin
insert into userlog(userId, username, action)values (param2, param3, 'UPDATE');
return 1;
end; //

delimiter //
create function AudituserINS(param2 int, param3 varchar(255)) returns int
Deterministic
begin
insert into userlog(userId, username, action)values (param2, param3, 'INSERT');
return 1;
end;//

delimiter //
create function AudituserDEL(param2 int, param3 varchar(255)) returns int
Deterministic
begin
insert into userlog(userId, username, action)values (param2, param3, 'DELETE');
return 1;
end;//

delimiter //
create table classlog(
	ID int primary key AUTO_INCREMENT,
    classId int not null,
    ownerId int not null,
    name VARCHAR(255),
    topicId INT,
	action VARCHAR(255),
	timeSTP TIMESTAMP Default current_timestamp
);//

delimiter //
create trigger classTRIGUPD
AFTER UPDATE on class
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditclassUPD(new.classId, new.ownerId, new.name, new.topicId);
    update members set classId = new.classId where classId = old.classId;
    update request set classId = new.classId where classId = old.classId;
END;//

delimiter //
create trigger classTRIGINS
AFTER insert on class
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditclassINS(new.classId, new.ownerId, new.name, new.topicId);
END;//

delimiter //
create trigger classTRIGDEL
before delete on class
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditclassDEL(old.classId, old.ownerId, old.name, old.topicId);
    delete from members where classId = old.classId;
    delete from request where classId = old.classId;
END;//

delimiter //
create function AuditclassUPD(param2 int, param3 int, param4 varchar(255), param5 int) returns int
Deterministic
begin
insert into classlog(classId, ownerId, name, topicId, action)values (param2, param3, param4, param5, 'UPDATE');
return 1;
end;//

delimiter //
create function AuditclassINS(param2 int, param3 int, param4 varchar(255), param5 int) returns int
Deterministic
begin
insert into classlog(classId, ownerId, name, topicId, action)values (param2, param3, param4, param5, 'INSERT');
return 1;
end;//

delimiter //
create function AuditclassDEL(param2 int, param3 int, param4 varchar(255), param5 int) returns int
Deterministic
begin
insert into classlog(classId, ownerId, name, topicId, action)values (param2, param3, param4, param5, 'DELETE');
return 1;
end;//

delimiter //
create table decklog(
	ID int primary key auto_increment,
    deckId int not null,
    name varchar(255),
    classId int,
    userId int,
    topicId int,
    creationDate TIMESTAMP,
    schoolId int,
    action varchar(255),
    timeSTP TIMESTAMP Default current_timestamp
);//

delimiter //
create trigger deckTRIGUPD
AFTER UPDATE on deck
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditdeckUPD(new.deckId, new.name, new.classId, new.userId, new.topicId, new.creationDate, new.schoolId);
    update cards set deckId = new.deckId where deckId = old.deckId;
END;//

delimiter //
create trigger deckTRIGINS
AFTER insert on deck
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditdeckINS(new.deckId, new.name, new.classId, new.userId, new.topicId, new.creationDate, new.schoolId);
END;//

delimiter //
create trigger deckTRIGDEL
before delete on deck
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditdeckDEL(old.deckId, old.name, old.classId, old.userId, old.topicId, old.creationDate, old.schoolId);
    delete from cards where deckId = old.deckId;
END;//

delimiter //
create function AuditdeckUPD(param2 int, param3 varchar(255), param4 int, param5 int, param6 int, param7 timestamp, param8 int) returns int
Deterministic
begin
insert into decklog(deckId, name, classId, userId, topicId, creationDate, schoolId, action)values (param2, param3, param4, param5, param6, param7, param8, 'UPDATE');
return 1;
end;//

delimiter //
create function AuditdeckINS(param2 int, param3 varchar(255), param4 int, param5 int, param6 int, param7 timestamp,param8 int) returns int
Deterministic
begin
insert into decklog(deckId, name, classId, userId, topicId, creationDate, schoolId, action)values (param2, param3, param4, param5, param6, param7, param8, 'INSERT');
return 1;
end;//

delimiter //
create function AuditdeckDEL(param2 int, param3 varchar(255), param4 int, param5 int, param6 int, param7 timestamp,param8 int) returns int
Deterministic
begin
insert into decklog(deckId, name, classId, userId, topicId, creationDate, schoolId, action)values (param2, param3, param4, param5, param6, param7, param8, 'DELETE');
return 1;
end;//

delimiter //
create table cardslog(
	ID int primary key auto_increment,
    cardId int not null,
    deckId int not null,
    cardName varchar(255),
    action varchar(255),
    timeSTP TIMESTAMP Default current_timestamp
    -- decsription of card is not put here because it is a description and not reasonable to be put in log table
);//

delimiter //
create trigger cardsTRIGUPD
AFTER UPDATE on cards
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditcardsUPD(new.cardId, new.deckId, new.cardName);
END;//

delimiter //
create trigger cardsTRIGINS
AFTER insert on cards
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditcardsINS(new.cardId, new.deckId, new.cardName);
END;//

delimiter //
create trigger cardsTRIGDEL
before delete on cards
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditcardsDEL(old.cardId, old.deckId, old.cardName);
END;//

delimiter //
create function AuditcardsUPD(param2 int, param3 int, param4 varchar(255)) returns int
Deterministic
begin
insert into cardslog(cardId, deckId, cardName, action)values (param2, param3, param4, 'UPDATE');
return 1;
end;//

delimiter //
create function AuditcardsINS(param2 int, param3 int, param4 varchar(255)) returns int
Deterministic
begin
insert into cardslog(cardId, deckId, cardName, action)values (param2, param3, param4, 'INSERT');
return 1;
end;//

delimiter //
create function AuditcardsDEL(param2 int, param3 int, param4 varchar(255)) returns int
Deterministic
begin
insert into cardslog(cardId, deckId, cardName, action)values (param2, param3, param4, 'DELETE');
return 1;
end;//

delimiter //
create table memberslog(
	ID int primary key auto_increment,
    userId int not null,
    classId int not null,
    action varchar(255),
    timeSTP TIMESTAMP Default current_timestamp
);//

delimiter //
create trigger membersTRIGUPD
AFTER UPDATE on members
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditmembersUPD(new.userId, new.classId);
END;//

delimiter //
create trigger membersTRIGINS
AFTER insert on members
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditmembersINS(new.userId, new.classId);
END;//

delimiter //
create trigger membersTRIGDEL
before delete on members
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditmembersDEL(old.userId, old.classId);
END;//

delimiter //
create function AuditmembersUPD(param2 int, param3 int) returns int
Deterministic
begin
insert into memberslog(userId, classId, action)values (param2, param3, 'UPDATE');
return 1;
end;//

delimiter //
create function AuditmembersINS(param2 int, param3 int) returns int
Deterministic
begin
insert into memberslog(userId, classId, action)values (param2, param3, 'INSERT');
return 1;
end;//

delimiter //
create function AuditmembersDEL(param2 int, param3 int) returns int
Deterministic
begin
insert into memberslog(userId, classId, action)values (param2, param3, 'DELETE');
return 1;
end;//

delimiter //
create table requestlog(
	ID int primary key auto_increment,
    userId int not null,
    classId int not null,
    action varchar(255),
    timeSTP TIMESTAMP Default current_timestamp
);//

delimiter //
create trigger requestTRIGUPD
AFTER UPDATE on request
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditrequestUPD(new.userId, new.classId);
END;//

delimiter //
create trigger requestTRIGINS
AFTER insert on request
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditrequestINS(new.userId, new.classId);
END;//

delimiter //
create trigger requestTRIGDEL
before delete on request
for each row
BEGIN
	-- function name goes here
    SET @Var_function = AuditrequestDEL(old.userId, old.classId);
END;//

delimiter //
create function AuditrequestUPD(param2 int, param3 int) returns int
Deterministic
begin
insert into requestlog(userId, classId, action)values (param2, param3, 'UPDATE');
return 1;
end;//

delimiter //
create function AuditrequestINS(param2 int, param3 int) returns int
Deterministic
begin
insert into requestlog(userId, classId, action)values (param2, param3, 'INSERT');
return 1;
end;//

delimiter //
create function AuditrequestDEL(param2 int, param3 int) returns int
Deterministic
begin
insert into requestlog(userId, classId, action)values (param2, param3, 'DELETE');
return 1;
end;//

delimiter //
INSERT INTO user(username, password)
VALUES ("Connie", "people123"),
  ("Friend", "people123"),
  ("Cindy", "people123"),
  ("John", "people123");
//

delimiter //
INSERT INTO school(schoolName, location)
VALUES ("City College", "Manhattan"),
  ("Hunter", "Manhattan"),
  ("College of Staten Island", "Staten Island"),
  ("Brooklyn College", "Brooklyn"),
  ("John Jay", "Manhattan"),
  ("BMCC", "Manhattan"),
  ("Wagner College", "Staten Island"),
  ("Baruch College", "Manhattan"),
  ("York College", "Queens"),
  ("Select the school", "NULL");
//

INSERT INTO topic(topicName)
VALUES ("Math"),
  ("Science"),
  ("Computer Science"),
  ("English"),
  ("Art"),
  ("History"),
  ("Music"),
  ("Select your topic");
//

INSERT INTO deck(name, userId, topicId, creationDate, schoolId)
VALUES ("Linear Algebra 346", 1, 1, CURDATE(), 2),
  ("Biology", 2, 2, DATE '2017-12-17', 1),
  ("Mozart", 2, 7, DATE '2018-08-29', 1),
  ("Chemistry", 3, 2, DATE '2016-12-17', 2),
  ("Algortihms", 1, 3, DATE '2017-05-15', 1),
  ("Shading", 1, 5, DATE '2017-12-01', 1),
  ("Literacy Techniques", 3, 4, DATE '2017-01-17', 2),
  ("American Revolution", 1, 6, DATE '2018-01-17', 1),
  ("Constitution", 1, 6, DATE '2018-05-17', 3),
  ("Data Structures", 3, 3, DATE '2018-8-30', 3),
  ("Set Theory Lecture", 4, 3, DATE '2018-09-29', 1),
  ("Halloween", 4, 6, DATE '2018-10-31', 1);
//

INSERT INTO cards(deckId, cardName, description)
VALUES (1, "Matrix", "asdfghjkl"),
  (1, "Eigen Value", "asdfghjkl"),
  (1, "Identity Matrix", "asdfghjkl"),
  (3, "Who is he?", "Austrian Composer"),
  (3, "When was he born?", "January 27, 1756"),
  (3, "How many children did he have?", "6 Children"),
  (3, "What is his full name?", "Wolfgang Amadeus Mozart"),
  (4, "What is chemistry", "The scientific displine involved with compoundscomposed of atoms"),
  (4, "What is an atom?", "The smallest component of an element"),
  (4, "Molecule is ____?", "the smallest particle in a chemical element"),
  (4, "Examples of molecules", "carbon dioxide, glucose, sucrose"),
  (5, "QuickSort", "QuickSort is a Divide and Conquer algorithm"),
  (5, "What is algorithm in computer science?", "An algorithm is a well-defined procedure that allows a computer to solve a problem"),
  (5, "Time Complexity", "The time complexity is the computational complexity that describes the amount of time it takes to run an algorithm"),
  (6, "Shading Art", "makes all the difference between an amateur drawing and a piece of art"),
  (6, "4 Types of Shading", "smooth, cross, hatching, slinky"),
  (7, "Literacy Techniques", "Allusion, Diction, Euphemism"),
  (8, "George Washington", "He led the Patriot forces to victory over the Briish and their allies"),
  (9, "What is the Constitution?", "A set of basic laws or principles for a country that describe the rights and duties of its citizens");
//

INSERT INTO cards(deckId, cardName, description)
VALUES (10, "Queue", "asdfghjkl"),
  (10, "Stack", "asdfghjkl"),
  (10, "Binary Tree", "asdfghjkl"),
  (11, "What is a set", "A set is a collection of elements"),
  (11, "Cardinality", "For a countable set A, the cardinality of A is the size of A"),
  (12, "When is Halloween?", "The night of October 31th"),
  (12, "What is Halloween also known as?", "The eve of All Saints' Day"),
  (12, "How is Halloween celebrated but children?", "Celebrated by children who dress in costume and solcit candy or other treats door-to-door");
//

INSERT INTO cards(deckId, cardName, description)
VALUES (2, "Chromosomes", "asdfghjkl"),
  (2, "Cell", "asdfghjkl"),
  (2, "Mitochondria", "asdfghjkl");
//

INSERT INTO class(ownerId, name, topicId, description)
VALUES (3, "Data Science", 3, "Resources for individuals"),
  (4, "Chemistry 101", 2, "From Atoms to Chemical"),
  (1, "Differentials", 1, "Derivatives 2.0 lol");
//

INSERT INTO deck(name, classId, topicId, creationDate)
VALUES ("Kernels", 1, 3, CURDATE()),
  ("Data Science", 1, 3, DATE '2018-05-15'),
  ("General Chem", 2, 2, DATE '2018-11-23');
//

INSERT INTO cards(deckId, cardName, description)
VALUES (13, "Program Exucation", "To load softwarem allocate resources, run & terminate when finished"),
  (13, "Disc access", "To read from or write to backing storage"),
  (13, "Interrupts", "For components such as the mouse to request servicing by the CPU"),
  (14, "Why do we need data?", "To make a more convincing argument & to predict the future"),
  (14, "The metric System", "K-H-D-U-d-c-m"),
  (14, "Key Error", "Error for when something can't be found in ca dictionary");
//

INSERT INTO members(userId, classId)
VALUES (1, 1),
  (1, 2),
  (4, 1),
  (3, 2),
  (2, 1);
//

INSERT INTO request(userId, classId)
VALUES -- (1, 3),
  (3, 3),
  (4, 3),
  (2, 3);
