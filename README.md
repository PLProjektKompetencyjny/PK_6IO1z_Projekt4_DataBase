# PK_6IO1z_Projekt4_DataBase

### [Starting DB container](/DB_startup.md)

Ograniczenia rezerwacji
 1) Gdy jest dziecko, to musi być minimum 1 osoba dorosła
 2) In reservations Price_gross = Room_price + (Num_of_adults * Adult_price) + (Num_of_childs * Child_price)
 3) Można zarezerwować pokój gdy jest mniej osób na rezerwacji niż łóżek
 4) Nie można rezerwować gdy jest mniej łóżek niż osób na rezerwacji

Jak sprawdzić czy pokój jest wolny?
Z tabeli rezerwacje używając where filtracja po Room_ID, posortować po End_date malejąco i wybrać TOP 1

![image](/Pictures/DB_model.png)