/*
Insert initial data
*/
SELECT
	INSERT_USER_ACCOUNT ('john.doe@wp.pl', 'myjohn', NULL);

SELECT
	INSERT_USER_ACCOUNT ('kevin.smith@wp.pl', 'mykevin', NULL);

SELECT
	INSERT_USER_ACCOUNT ('jack.connor@wp.pl', 'myjack', NULL);

INSERT INTO
	USER_DETAILS (
		USER_ID,
		NIP_NUM,
		NAME,
		SURNAME,
		PHONE_NUM,
		CITY,
		POSTAL_CODE,
		STREET,
		BUILDING_NUM
	)
VALUES
	(
		1,
		NULL,
		'John',
		'Doe',
		'+44123456789',
		'London',
		'12-324',
		'Hampson',
		'12'
	),
	(
		2,
		NULL,
		'Kevin',
		'Smith',
		'+44123456789',
		'Birmingham',
		'10-944',
		'Wellington',
		'22'
	),
	(
		3,
		NULL,
		'Jack',
		'Connor',
		'+44123456789',
		'Dudley',
		'10-881',
		'Brooke',
		'33'
	);

DO $$
DECLARE
	user_id_var int;
BEGIN
	SELECT
		insert_user_account('ADMIN','mypass', NULL)
	INTO user_id_var;

	UPDATE user_view
	SET user_is_admin = TRUE
	WHERE user_id = user_id_var;
	
END $$;

UPDATE user_view
SET user_activation_code = NULL;

INSERT INTO
	ROOM_TYPE (
		NUM_OF_SINGLE_BEDS,
		NUM_OF_DOUBLE_BEDS,
		NUM_OF_CHILD_BEDS,
		ADULT_PRICE_GROSS,
		CHILD_PRICE_GROSS,
		PHOTOS_DIR
	)
VALUES
  -- If new assets added in the future for the same room they must be seperated by semicolon ';' ie 'assets/imgs/rooms/1/1.jpg;assets/imgs/rooms/1/2.jpg'
	(0, 1, 0, 40, 0, 'assets/imgs/rooms/1/1.jpg'),
	(0, 1, 0, 20, 0, 'assets/imgs/rooms/2/1.jpg'),
	(0, 2, 2, 100, 50, 'assets/imgs/rooms/3/1.jpg'),
	(1, 0, 0, 30, 0, 'assets/imgs/rooms/4/1.jpg'),
	(1, 1, 0, 60, 0, 'assets/imgs/rooms/5/1.jpg'),
	(2, 2, 3, 80, 30, 'assets/imgs/rooms/6/1.jpg');

INSERT INTO
	ROOM (ID, ROOM_TYPE_ID, ROOM_PRICE_GROSS)
VALUES
	(1, 1, 20),
	(2, 2, 10),
	(3, 3, 60),
	(4, 4, 10),
	(5, 5, 30),
	(6, 6, 40),
	(7, 1, 20),
	(8, 2, 10),
	(9, 3, 60),
	(10, 4, 10),
	(11, 5, 30),
	(12, 6, 40),
	(13, 1, 20),
	(14, 2, 10),
	(15, 3, 60),
	(16, 4, 10),
	(17, 5, 30),
	(18, 6, 40);

INSERT INTO
	SERVICE (NAME, UNIT_PRICE)
VALUES
	('Parking', 25),
	('Breakfast', 30),
	('Dinner', 50),
	('Swimming pool', 100),
	('Champagne', 300);


INSERT INTO
	RESERVATION_VIEW (
		RESERVATION_CUSTOMER_ID,
		ROOM_NUMBER_OF_ADULTS,
		ROOM_NUMBER_OF_CHILDREN,
		RESERVATION_START_DATE,
		RESERVATION_END_DATE,
		RESERVATION_ROOM_ID
	)
VALUES
	(1, 1, 0, (current_date + 10), (current_date + 15), 10),
	(1, 2, 2, (current_date + 10), (current_date + 15), 12);

INSERT INTO
	SERVICE_VIEW (
		SERVICE_RESERVATION_ID,
		SERVICE_ID,
		SERVICE_QUANTITY
	)
VALUES
	(1,1,3),
	(1,2,5),
	(1,4,3);

INSERT INTO
	RESERVATION_VIEW (
		RESERVATION_CUSTOMER_ID,
		ROOM_NUMBER_OF_ADULTS,
		ROOM_NUMBER_OF_CHILDREN,
		RESERVATION_START_DATE,
		RESERVATION_END_DATE,
		RESERVATION_ROOM_ID
	)
VALUES
	(2, 1, 0, (current_date + 1), (current_date + 5), 13),
	(2, 1, 0, (current_date + 1), (current_date + 5), 14),
	(2, 1, 0, (current_date + 1), (current_date + 5), 16),
	(2, 1, 0, (current_date + 1), (current_date + 5), 17);

INSERT INTO
	SERVICE_VIEW (
		SERVICE_RESERVATION_ID,
		SERVICE_ID,
		SERVICE_QUANTITY
	)
VALUES
	(2,2,3),
	(2,5,5);

INSERT INTO
	RESERVATION_VIEW (
		RESERVATION_CUSTOMER_ID,
		ROOM_NUMBER_OF_ADULTS,
		ROOM_NUMBER_OF_CHILDREN,
		RESERVATION_START_DATE,
		RESERVATION_END_DATE,
		RESERVATION_ROOM_ID
	)
VALUES
	(3, 1, 0, (current_date + 20), (current_date + 30), 1),
	(3, 1, 0, (current_date + 20), (current_date + 30), 2),
	(3, 2, 2, (current_date + 20), (current_date + 30), 3);

INSERT INTO
	SERVICE_VIEW (
		SERVICE_RESERVATION_ID,
		SERVICE_ID,
		SERVICE_QUANTITY
	)
VALUES
	(3,1,1),
	(3,2,2),
	(3,3,3),
	(3,4,4),
	(3,5,5);

INSERT INTO
	RESERVATION_VIEW (
		RESERVATION_CUSTOMER_ID,
		ROOM_NUMBER_OF_ADULTS,
		ROOM_NUMBER_OF_CHILDREN,
		RESERVATION_START_DATE,
		RESERVATION_END_DATE,
		RESERVATION_ROOM_ID
	)
VALUES
	(3, 1, 0, (current_date  + 41), (current_date + 42), 4);

INSERT INTO
	SERVICE_VIEW (
		SERVICE_RESERVATION_ID,
		SERVICE_ID,
		SERVICE_QUANTITY
	)
VALUES
	(4,1,10);

INSERT INTO
	RESERVATION_VIEW (
		RESERVATION_CUSTOMER_ID,
		ROOM_NUMBER_OF_ADULTS,
		ROOM_NUMBER_OF_CHILDREN,
		RESERVATION_START_DATE,
		RESERVATION_END_DATE,
		RESERVATION_ROOM_ID
	)
VALUES
	(3, 1, 0, (current_date + 33), (current_date + 35), 5),
	(3, 2, 3, (current_date + 33), (current_date + 35), 6);

INSERT INTO
	SERVICE_VIEW (
		SERVICE_RESERVATION_ID,
		SERVICE_ID,
		SERVICE_QUANTITY
	)
VALUES
	(5,2,20),
    (5,3,20);

INSERT INTO
	RESERVATION_VIEW (
		RESERVATION_CUSTOMER_ID,
		ROOM_NUMBER_OF_ADULTS,
		ROOM_NUMBER_OF_CHILDREN,
		RESERVATION_START_DATE,
		RESERVATION_END_DATE,
		RESERVATION_ROOM_ID
	)
VALUES
	(1, 1, 0, (current_date + 100), (current_date + 120), 7),
	(1, 1, 0, (current_date + 100), (current_date + 120), 8),
	(1, 2, 2, (current_date + 100), (current_date + 120), 9);

INSERT INTO
	INVOICE_VIEW (INVOICE_RESERVATION_ID)
VALUES
	(6),
	(2),
	(3),
	(1);

UPDATE INVOICE_VIEW
SET
	INVOICE_IS_PAID = TRUE
WHERE
	INVOICE_ID IN (2, 1, 4);