package com.example.gas.controller;

import com.example.gas.model.GasQuantity;
import com.example.gas.service.GasQuantityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/gas")
public class GasQuantityController {

    @Autowired
    private GasQuantityService gasQuantityService;

    @GetMapping("/{driverId}")
    public ResponseEntity<?> getGasQuantityByDriverId(@PathVariable Long driverId) {
        Optional<GasQuantity> gasQuantityOptional = gasQuantityService.findByDriverId(driverId);
        if (gasQuantityOptional.isPresent()) {
            return ResponseEntity.ok(gasQuantityOptional.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/update")
    public ResponseEntity<?> updateGasQuantity(@RequestBody GasQuantity gasQuantity) {
        GasQuantity updatedGasQuantity = gasQuantityService.saveGasQuantity(gasQuantity);
        return ResponseEntity.ok(updatedGasQuantity);
    }
}

