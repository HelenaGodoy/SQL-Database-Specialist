-- Tabela de Clientes
create table clients (
    idClient int auto_increment primary key,
    firstName varchar(50) not null,
    lastName varchar(50) not null,
    cpf char(11) unique not null,
    phoneNumber varchar(15),
    email varchar(100)
);

-- Tabela de Veículos
create table vehicles (
    idVehicle int auto_increment primary key,
    idClient int,
    licensePlate varchar(10) not null unique,
    brand varchar(50) not null,
    model varchar(50) not null,
    year int not null,
    constraint fk_vehicle_client foreign key (idClient) references clients(idClient)
);

-- Tabela de Funcionários
create table employees (
    idEmployee int auto_increment primary key,
    firstName varchar(50) not null,
    lastName varchar(50) not null,
    role varchar(50) not null, -- Mecânico, Supervisor, etc.
    salary decimal(10, 2)
);

-- Tabela de Serviços
create table services (
    idService int auto_increment primary key,
    serviceName varchar(100) not null,
    price decimal(10, 2) not null
);

-- Tabela de Ordens de Serviço
create table serviceOrders (
    idServiceOrder int auto_increment primary key,
    idVehicle int not null,
    idService int not null,
    idEmployee int not null,
    serviceDate date not null,
    totalCost decimal(10, 2),
    status enum('Pendente', 'Em andamento', 'Concluído', 'Cancelado') default 'Pendente',
    constraint fk_order_vehicle foreign key (idVehicle) references vehicles(idVehicle),
    constraint fk_order_service foreign key (idService) references services(idService),
    constraint fk_order_employee foreign key (idEmployee) references employees(idEmployee)
);

-- Tabela de Peças
create table parts (
    idPart int auto_increment primary key,
    partName varchar(100) not null,
    partCost decimal(10, 2) not null,
    stock int not null default 0
);

-- Tabela de Relacionamento entre Peças e Ordens de Serviço
create table serviceOrderParts (
    idServiceOrder int,
    idPart int,
    quantity int,
    constraint fk_sop_serviceOrder foreign key (idServiceOrder) references serviceOrders(idServiceOrder),
    constraint fk_sop_part foreign key (idPart) references parts(idPart),
    primary key (idServiceOrder, idPart)
);

-- Tabela de Fornecedores de Peças
create table suppliers (
    idSupplier int auto_increment primary key,
    supplierName varchar(100) not null,
    phoneNumber varchar(15),
    email varchar(100),
    cnpj char(14) unique
);

-- Tabela de Relacionamento entre Peças e Fornecedores
create table supplierParts (
    idSupplier int,
    idPart int,
    constraint fk_supplierPart_supplier foreign key (idSupplier) references suppliers(idSupplier),
    constraint fk_supplierPart_part foreign key (idPart) references parts(idPart),
    primary key (idSupplier, idPart)
);
-- Clientes
insert into clients (firstName, lastName, cpf, phoneNumber, email) values 
('Helena', 'Godoy', '12345678901', '11999999999', 'helena@example.com'),
('Kayo', 'Silva', '98765432100', '11988888888', 'kayo@example.com');

-- Veículos
insert into vehicles (idClient, licensePlate, brand, model, year) values 
(1, 'ABC1234', 'Toyota', 'Corolla', 2020),
(2, 'XYZ9876', 'Honda', 'Civic', 2019);

-- Funcionários
insert into employees (firstName, lastName, role, salary) values 
('Carlos', 'Mecânico', 'Mecânico', 2500.00),
('João', 'Supervisor', 'Supervisor', 3500.00);

-- Serviços
insert into services (serviceName, price) values 
('Troca de Óleo', 150.00),
('Alinhamento', 100.00),
('Balanceamento', 120.00);

-- Ordens de Serviço
insert into serviceOrders (idVehicle, idService, idEmployee, serviceDate, totalCost, status) values 
(1, 1, 1, '2024-09-01', 150.00, 'Concluído'),
(2, 2, 2, '2024-09-02', 100.00, 'Em andamento');

-- Peças
insert into parts (partName, partCost, stock) values 
('Filtro de Óleo', 30.00, 50),
('Pneu 175/65', 250.00, 100);

-- Relacionamento entre Peças e Ordens de Serviço
insert into serviceOrderParts (idServiceOrder, idPart, quantity) values 
(1, 1, 1), 
(2, 2, 4);

-- Fornecedores
insert into suppliers (supplierName, phoneNumber, email, cnpj) values 
('Fornecedor A', '11997777777', 'fornecedorA@example.com', '12345678000199'),
('Fornecedor B', '11996666666', 'fornecedorB@example.com', '98765432000100');

-- Relacionamento entre Peças e Fornecedores
insert into supplierParts (idSupplier, idPart) values 
(1, 1),
(2, 2);

--Recuperar todos os serviços realizados em um determinado veículo.
select v.licensePlate, s.serviceName, so.serviceDate, so.totalCost
from serviceOrders so
join vehicles v on so.idVehicle = v.idVehicle
join services s on so.idService = s.idService
where v.licensePlate = 'ABC1234';

--Filtrar ordens de serviço por status "Em andamento".
select so.idServiceOrder, c.firstName, v.licensePlate, s.serviceName, so.status
from serviceOrders so
join vehicles v on so.idVehicle = v.idVehicle
join clients c on v.idClient = c.idClient
join services s on so.idService = s.idService
where so.status = 'Em andamento';

--Calcular o valor total das ordens de serviço, somando o preço dos serviços e o custo das peças usadas.
select so.idServiceOrder, sum(s.price + (p.partCost * sop.quantity)) as totalOrderValue
from serviceOrders so
join services s on so.idService = s.idService
join serviceOrderParts sop on so.idServiceOrder = sop.idServiceOrder
join parts p on sop.idPart = p.idPart
group by so.idServiceOrder;

--Exibir todas as ordens de serviço ordenadas pela data de realização.
select so.idServiceOrder, c.firstName, v.licensePlate, s.serviceName, so.serviceDate
from serviceOrders so
join vehicles v on so.idVehicle = v.idVehicle
join clients c on v.idClient = c.idClient
join services s on so.idService = s.idService
order by so.serviceDate desc;

--Filtrar funcionários que participaram de mais de uma ordem de serviço.
select e.firstName, e.lastName, count(so.idServiceOrder) as totalOrders
from employees e
join serviceOrders so on e.idEmployee = so.idEmployee
group by e.idEmployee
having count(so.idServiceOrder) > 1;

--Exibir o nome do cliente, a placa do veículo e os serviços realizados em cada veículo.
select c.firstName, v.licensePlate, s.serviceName, so.serviceDate
from serviceOrders so
join vehicles v on so.idVehicle = v.idVehicle
join clients c on v.idClient = c.idClient
join services s on so.idService = s.idService;


