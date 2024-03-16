Backend będzie się łączył do widoków zamiast do tabel.
Uzytkownik uzyty na backendzie nie bedzie mial dostepu bezposrednio do tabel.

View types:
1. Customers
2. Reservations
3. Rooms
4. Invoices
5. Admins

Kazdy widok ma posiada przypiete 3 trigery:
- INSTEAD OF INSERT
- INSTEAD OF UPDATE
- INSTEAD OF DELETE

Kazdy triger wyzwala odpowiednią funckje:
- INSERT function
- UPDATE function
- DELETE function

# Naming
## Triggers:
    - ioi <- for trigger INSTEAD OF INSERT
    - iou <- for trigger INSTEAD OF UPDATE
    - iod <- for trigger INSTEAD OF DELETE

## Functions
    - <view_name>_<operation>

## Views:
    - <view_type>_view