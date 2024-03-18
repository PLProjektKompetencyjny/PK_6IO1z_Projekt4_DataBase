CREATE OR REPLACE FUNCTION admins_view_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.isActive = true THEN
        INSERT INTO Admins (user_name, password, isActive, E_mail, Phone_num)
		VALUES (NEW.user_name, NEW.password, NEW.isActive, NEW.E_mail, NEW.Phone_num);
		RETURN NEW;
    ELSE
        RAISE EXCEPTION 'isActive must be true for insertion';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ioi
INSTEAD OF INSERT ON admins_view
FOR EACH ROW
EXECUTE FUNCTION admins_view_insert();