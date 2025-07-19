package com.workshop.todoback.repository; // IMPORTANT: Updated package name

import com.workshop.todoback.model.Todo; // IMPORTANT: Import Todo from the new model package
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TodoRepository extends JpaRepository<Todo, Long> { // Now managing 'Todo'
    // No methods needed here for basic CRUD
}