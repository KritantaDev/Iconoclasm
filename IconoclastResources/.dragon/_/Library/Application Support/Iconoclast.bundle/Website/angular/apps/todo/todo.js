(function() {
    'use strict';
    angular
        .module('app')
        .factory('todoStorage', TodoStorage)
        .controller('TodoCtrl', TodoCtrl);

        TodoStorage.$inject = ['ngStore'];
        function TodoStorage(ngStore) {
            return ngStore.model('todo');
        }

        TodoCtrl.$inject = ['$scope', '$location', '$filter', 'todoStorage'];
        function TodoCtrl($scope, $location, $filter, todoStorage) {
            var vm = $scope;
            var todos = vm.todos = todoStorage.findAll();

            vm.newTodo = '';
            vm.remainingCount = $filter('filter')(todos, {completed: false}).length;

            vm.location = $location;

            vm.$watch('location.path()', function (path) {
                vm.statusFilter = { '/app/todo/active': {completed: false}, '/app/todo/completed': {completed: true} }[path];
            });

            vm.$watch('remainingCount == 0', function (val) {
                vm.allChecked = val;
            });

            vm.addTodo = addTodo;
            vm.editTodo = editTodo;
            vm.doneEditing = doneEditing;
            vm.revertEditing = revertEditing;
            vm.removeTodo = removeTodo;
            vm.todoCompleted = todoCompleted;
            vm.clearCompletedTodos = clearCompletedTodos;
            vm.markAll = markAll;
            
            function addTodo() {
                var newTodo = vm.newTodo.trim();
                if (newTodo.length === 0) {
                    return;
                }

                var item = {
                    id: todoStorage.nextId(),
                    title: newTodo,
                    completed: false
                };
                todos.push( todoStorage.create(item) );

                vm.newTodo = '';
                vm.remainingCount++;
            };

            function editTodo(todo) {
                todo.editedTodo = true;
                // Clone the original todo to restore it on demand.
                vm.originalTodo = angular.extend({}, todo);
            };

            function doneEditing(todo) {
                todo.editedTodo = false;
                todo.title = todo.title.trim();

                if (!todo.title) {
                    vm.removeTodo(todo);
                }

                todoStorage.update(todo);
            };

            function revertEditing(todo) {
                todos[todos.indexOf(todo)] = vm.originalTodo;
                vm.doneEditing(vm.originalTodo);
            };

            function removeTodo(todo) {
                vm.remainingCount -= todo.completed ? 0 : 1;
                todos.splice(todos.indexOf(todo), 1);
                todoStorage.destroy(todo);
            };

            function todoCompleted(todo) {
                vm.remainingCount += todo.completed ? -1 : 1;
                todoStorage.update(todo);
            };

            function clearCompletedTodos() {
                todos.filter(function (todo) {
                    if(todo.completed){
                        todos.splice(todos.indexOf(todo), 1);
                        todoStorage.destroy(todo);
                    }
                });
            };

            function markAll(completed) {
                todos.forEach(function (todo) {
                    todo.completed = completed;
                    todoStorage.update(todo);
                });
                vm.remainingCount = !completed ? todos.length : 0;
            };
        }
})();
