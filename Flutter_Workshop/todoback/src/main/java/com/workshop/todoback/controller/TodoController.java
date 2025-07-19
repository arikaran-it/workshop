package com.workshop.todoback.controller; // IMPORTANT: Updated package name

import com.workshop.todoback.model.Todo; // IMPORTANT: Import Todo from the model package
import com.workshop.todoback.repository.TodoRepository; // IMPORTANT: Import from the repository package

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/todos")
public class TodoController {

    private final TodoRepository todoItemRepository;

    @Autowired
    public TodoController(TodoRepository todoItemRepository) {
        this.todoItemRepository = todoItemRepository;
    }

    // GET all todo items
    @GetMapping
    public List<Todo> getAllTodoItems() { // Changed return type to Todo
        return todoItemRepository.findAll();
    }

    // GET a single todo item by ID
    @GetMapping("/{id}")
    public ResponseEntity<Todo> getTodoItemById(@PathVariable Long id) { // Changed return type to Todo
        Optional<Todo> todo = todoItemRepository.findById(id); // Changed type to Todo
        return todo.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // POST (Create) a new todo item
    @PostMapping
    public ResponseEntity<Todo> createTodoItem(@RequestBody Todo todo) { // Changed parameter type to Todo
        Todo savedTodo = todoItemRepository.save(todo); // Changed type to Todo
        return new ResponseEntity<>(savedTodo, HttpStatus.CREATED);
    }

    // PUT (Update) an existing todo item
    @PutMapping("/{id}")
    public ResponseEntity<Todo> updateTodoItem(@PathVariable Long id, @RequestBody Todo todoDetails) { // Changed parameter type to Todo
        Optional<Todo> optionalTodo = todoItemRepository.findById(id); // Changed type to Todo

        if (optionalTodo.isPresent()) {
            Todo existingTodo = optionalTodo.get(); // Changed type to Todo
            existingTodo.setDescription(todoDetails.getDescription());
            existingTodo.setCompleted(todoDetails.isCompleted());

            Todo updatedTodo = todoItemRepository.save(existingTodo); // Changed type to Todo
            return ResponseEntity.ok(updatedTodo);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // DELETE a todo item
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTodoItem(@PathVariable Long id) {
        if (todoItemRepository.existsById(id)) {
            todoItemRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}