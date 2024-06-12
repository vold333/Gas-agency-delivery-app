package com.example.gas.repository;

import com.example.gas.model.OrderForm;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderFormRepository extends JpaRepository<OrderForm, Long> {
    List<OrderForm> findByDriverId(Long driverId);
}

