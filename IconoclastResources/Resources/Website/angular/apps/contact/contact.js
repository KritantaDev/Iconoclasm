(function() {
    'use strict';
    angular
        .module('app')
        .factory('contactStorage', ContactStorage)
        .factory('contactGroupStorage', ContactGroupStorage)
        .controller('ContactCtrl', ContactCtrl);

        ContactStorage.$inject = ['ngStore'];
        function ContactStorage(ngStore) {
            return ngStore.model('contact');
        }

        ContactGroupStorage.$inject = ['ngStore'];
        function ContactGroupStorage(ngStore) {
            return ngStore.model('contact-group');
        }

        ContactCtrl.$inject = ['$scope', '$http', '$filter', 'contactStorage'];
        function ContactCtrl($scope, $http, $filter, contactStorage) {
          var vm = $scope;
          vm.items = contactStorage.findAll();

          if(vm.items.length == 0){
            populateData();
          }
          selectOne();

          function populateData(){
            $http.get('apps/contact/contacts.json').then(function (resp) {
              vm.items = resp.data.items;
              vm.items.forEach(function (item) {
                  contactStorage.create(item);
              });
              selectOne();
            });
          }

          vm.filter = '';
          vm.groups = [
            {name: 'Coworkers'}, 
            {name: 'Family'}, 
            {name: 'Friends'}, 
            {name: 'Partners'}, 
            {name: 'Group'}
          ];

          vm.createGroup = createGroup;
          vm.checkItem = checkItem;
          vm.deleteGroup = deleteGroup;
          vm.selectGroup = selectGroup;
          vm.selectItem = selectItem;
          vm.deleteItem = deleteItem;
          vm.createItem = createItem;
          vm.editItem = editItem;
          vm.doneEditing = doneEditing;

          function createGroup(){
            var group = {name: 'New Group'};
            group.name = vm.checkItem(group, vm.groups, 'name');
            vm.groups.push(group);
          };

          function checkItem(obj, arr, key){
            var i=0;
            angular.forEach(arr, function(item) {
              if(item[key].indexOf( obj[key] ) == 0){
                var j = item[key].replace(obj[key], '').trim();
                if(j){
                  i = Math.max(i, parseInt(j)+1);
                }else{
                  i = 1;
                }
              }
            });
            return obj[key] + (i ? ' '+i : '');
          };

          function deleteGroup(item){
            vm.groups.splice(vm.groups.indexOf(item), 1);
          };

          function selectGroup(item){    
            angular.forEach(vm.groups, function(item) {
              item.selected = false;
            });
            vm.group = item;
            vm.group.selected = true;
            vm.filter = item.name;
          };

          function selectItem(item){
            angular.forEach(vm.items, function(item) {
              item.selected = false;
              item.editing = false;
            });
            vm.item = item;
            vm.item.selected = true;
          };

          function deleteItem(item){
            vm.items.splice(vm.items.indexOf(item), 1);
            contactStorage.destroy(item);
            selectOne();
          };

          function createItem(){
            var item = {
              id: contactStorage.nextId(),
              group: 'Friends',
              avatar:'../assets/images/a0.jpg'
            };
            vm.items.push(item);
            vm.selectItem(item);
            vm.item.editing = true;
            contactStorage.create(item);
          };

          function editItem(item){
            if(item && item.selected){
              item.editing = true;
            }
          };

          function doneEditing(item){
            item.editing = false;
            contactStorage.update(item);
          };

          function selectOne(){
            vm.items.length && selectItem($filter('orderBy')(vm.items, 'first')[0]);
          }

        }
})();
