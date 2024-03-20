# PK_6IO1z_Projekt4_DataBase

### [Starting DB container](/DB_startup.md)

Backend będzie się łączył do widoków zamiast do tabel.
Uzytkownik uzyty na backendzie nie bedzie mial dostepu bezposrednio do tabel.

View types:
1. Customers
2. Reservations
3. Rooms
4. Invoices
5. Users

Kazdy widok ma posiada przypiete 3 triggery:
- INSTEAD OF INSERT
- INSTEAD OF UPDATE
- INSTEAD OF DELETE

Kazdy trigger wyzwala odpowiednią funckje:
- INSERT function
- UPDATE function
- DELETE function

# Naming
## Triggers:
    - ioi <- for trigger INSTEAD OF INSERT
    - iou <- for trigger INSTEAD OF UPDATE
    - iod <- for trigger INSTEAD OF DELETE

## Functions
    - <operation>_<view_name>

## Views:
    - <view_type>_view

Ograniczenia rezerwacji
 1) Gdy jest dziecko, to musi być minimum 1 osoba dorosła
 2) In reservations Price_gross = Room_price + (Num_of_adults * Adult_price) + (Num_of_childs * Child_price)
 3) Można zarezerwować pokój gdy jest mniej osób na rezerwacji niż łóżek
 4) Nie można rezerwować gdy jest mniej łóżek niż osób na rezerwacji

Jak sprawdzić czy pokój jest wolny?
Z tabeli rezerwacje używając where filtracja po Room_ID, posortować po End_date malejąco i wybrać TOP 1

![image](/Pictures/DB_model.png)