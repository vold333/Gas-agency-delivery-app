package com.example.gas.repository;

import com.example.gas.model.GasQuantity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GasQuantityRepository extends JpaRepository<GasQuantity, Long> {
    Optional<GasQuantity> findByDriverId(Long driverId);
}

