package com.example.gas.service;

import com.example.gas.model.Driver;
import com.example.gas.repository.DriverRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class DriverService {

    @Autowired
    private DriverRepository driverRepository;

    public Optional<Driver> findByEmail(String email) {
        return driverRepository.findByEmail(email);
    }

    public Driver saveDriver(Driver driver) {
        return driverRepository.save(driver);
    }
}

