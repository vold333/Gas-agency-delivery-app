package com.example.gas.service;

import com.example.gas.model.GasQuantity;
import com.example.gas.repository.GasQuantityRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class GasQuantityService {

    @Autowired
    private GasQuantityRepository gasQuantityRepository;

    public Optional<GasQuantity> findByDriverId(Long driverId) {
        return gasQuantityRepository.findByDriverId(driverId);
    }

    public GasQuantity saveGasQuantity(GasQuantity gasQuantity) {
        Optional<GasQuantity> existingGasQuantityOpt = gasQuantityRepository.findByDriverId(gasQuantity.getDriverId());
        if (existingGasQuantityOpt.isPresent()) {
            GasQuantity existingGasQuantity = existingGasQuantityOpt.get();

            if (gasQuantity.getLpgQuantity() != null) {
                existingGasQuantity.setLpgQuantity(gasQuantity.getLpgQuantity());
            }
            if (gasQuantity.getButaneQuantity() != null) {
                existingGasQuantity.setButaneQuantity(gasQuantity.getButaneQuantity());
            }
            if (gasQuantity.getPropaneQuantity() != null) {
                existingGasQuantity.setPropaneQuantity(gasQuantity.getPropaneQuantity());
            }

            return gasQuantityRepository.save(existingGasQuantity);
        } else {
            return gasQuantityRepository.save(gasQuantity);
        }
    }
}
