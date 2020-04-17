(function() {
    'use strict';
    angular
        .module('app')
        .factory('noteStorage', NoteStorage)
        .controller('NoteCtrl', NoteCtrl)
        .controller('NoteItemCtrl', NoteItemCtrl);

        NoteStorage.$inject = ['ngStore'];
        function NoteStorage(ngStore) {
            return ngStore.model('note');
        }

        NoteCtrl = ['$scope', '$location', '$filter', 'ngStore', 'noteStorage'];
        function NoteCtrl($scope, $location, $filter, ngStore, noteStorage) {
          var vm = $scope;
          vm.items = noteStorage.findAll();
          vm.newItem = '';

          vm.addItem = addItem;

          function addItem() {
              var newItem = vm.newItem.trim();
              if (newItem.length === 0) {
                  return;
              }
              var item = {
                id: noteStorage.nextId(),
                title: newItem,
                color: 'white',
                date: Date.now()
              };
              vm.items.push(noteStorage.create(item));
              vm.newItem = '';
          };
        }

        NoteItemCtrl.$inject = ['$scope', 'noteStorage', '$state', '$stateParams'];
        function NoteItemCtrl($scope, noteStorage, $state, $stateParams) {
          var vm = $scope;
          vm.colors = ['white', 'indigo', 'pink', 'light-blue', 'amber', 'blue', 'green'];
          vm.item = noteStorage.find($stateParams);
          
          vm.$watch("item", function() {
            noteStorage.update($scope.item);
          }, true);

          vm.removeItem = removeItem;
          function removeItem(item){
            noteStorage.destroy(item);
            $state.go('app.note.list');
          }
      }
})();
