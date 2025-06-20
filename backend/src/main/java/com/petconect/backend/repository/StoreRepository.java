package com.petconect.backend.repository;

import com.petconect.backend.model.Store;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StoreRepository extends JpaRepository<Store, Long> {
} 