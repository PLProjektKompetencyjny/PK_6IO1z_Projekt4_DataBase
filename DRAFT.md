# Views Available from Backend
- customer_view
- reservation_view

    | View column name               | Update access |
    |--------------------------------|---------------|
    | reservation_id                 |               |
    | reservation_customer_id        |               |
    | reservation_status             |               |
    | reservation_status_id          |       X       |
    | reservation_number_of_adults   |       X       |
    | reservation_number_of_children |       X       |
    | reservation_start_date         |       X       |
    | reservation_end_date           |       X       |
    | reservation_price_gross        |       X       |
    | reservation_is_paid            |       X       |
    | reservation_room_id            |       X       |
    | reservation_last_modified_by   |       X       |
    | reservation_last_modified_at   |       X       |
- room_view

    | View column name            | Update access |
    |-----------------------------|---------------|
    | room_id                     |               |
    | room_status_id              |       X       |
    | room_number_of_single_beds  |               |
    | room_number_of_double_beds  |               |
    | room_number_of_child_beds   |               |
    | room_gross_price            |               |
    | room_gross_price_adult      |               |
    | room_gross_price_child      |               |
    | room_gross_photos_dir       |               |
    | room_last_modified_by       |       X       |
    | room_last_modified_at       |       X       |
- invoice_view

    | View column name         | Update access |
    |--------------------------|---------------|
    | invoice_id               |               |
    | invoice_reservation_id   |               |
    | invoice_date             |               |
    | invoice_status_id        |       X       |
    | invoice_last_modified_by |       X       |
    | invoice_last_modified_at |       X       |
- user_view


# Drafts
## Testing Block
    DO $$
    DECLARE mydate timestamp;
    BEGIN
        Select start_date into mydate from Reservation;
        RAISE NOTICE 'Value: %', mydate = '2024-03-31';
    END $$;

## INSERT INTO reservation_view
    /*
    Columns to insert statement:
        - reservation_customer_id,
        - reservation_number_of_adults
        - reservation_number_of_children,
        - reservation_price_gross
        - reservation_start_date,
        - reservation_end_date,
        - reservation_room_id (only one)

    */
    /*
    Insert reservation for 1 room
    */

    INSERT INTO reservation_view (reservation_customer_id, reservation_number_of_adults, reservation_number_of_children, reservation_price_gross, reservation_start_date, reservation_end_date, reservation_room_id)
    VALUES(1,1,1,1,'2024-03-21','2024-03-22',1);

    /*
    Insert reservation for 2 and more rooms
    */

    INSERT INTO reservation_view (reservation_customer_id, reservation_number_of_adults, reservation_number_of_children, reservation_price_gross, reservation_start_date, reservation_end_date, reservation_room_id)
    VALUES
        (1,1,1,1,'2024-03-21','2024-03-22',1),
        (1,1,1,1,'2024-03-21','2024-03-22',2);

## UPDATE reservation_view
    /*
    Kolumny do potencjalnych zmian:
        - reservation_status_id
        - reservation_number_of_adults
        - reservation_number_of_children
        - reservation_start_date
        - reservation_end_date
        - reservation_price_gross
        - reservation_is_paid
        - reservation_room_id

    Kolumny przekazywane w UPDATE: dowolne

    ERRORS:
    Message: UPDATE 0 <- wrong WHERE clause was set on view UPDATE statement

    */