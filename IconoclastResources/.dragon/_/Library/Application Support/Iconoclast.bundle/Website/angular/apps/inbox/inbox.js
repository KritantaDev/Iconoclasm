(function() {
    'use strict';
    angular
      .module('app')
      .factory('inboxStorage', InboxStorage)
      .directive('labelColor', LabelColor)
      .controller('MainCtrl', MainCtrl)
      .controller('ListCtrl', ListCtrl)
      .controller('DetailCtrl', DetailCtrl)
      .controller('NewCtrl', NewCtrl);

      InboxStorage.$inject = ['ngStore'];
      function InboxStorage(ngStore) {
          return ngStore.model('mail');
      }

      function MainCtrl($scope) {
        var vm = $scope;
        vm.folds = [
          {name: 'Inbox', filter:''},
          {name: 'Starred', filter:'starred'},
          {name: 'Sent', filter:'sent'},
          {name: 'Important', filter:'important'},
          {name: 'Draft', filter:'draft'},
          {name: 'Trash', filter:'trash'}
        ];

        vm.labels = [
          {name: 'Angular', filter:'angular', color:'#23b7e5'},
          {name: 'Bootstrap', filter:'bootstrap', color:'#7266ba'},
          {name: 'Client', filter:'client', color:'#fad733'},
          {name: 'Work', filter:'work', color:'#27c24c'}
        ];

        vm.labelClass = labelClass;
        vm.addLabel = addLabel;

        function addLabel(){
          vm.labels.push(
            {
              name: $scope.newLabel.name,
              filter: angular.lowercase($scope.newLabel.name),
              color: '#ccc'
            }
          );
          vm.newLabel.name = '';
        }

        function labelClass(label) {
          return {
            'b-l-info': angular.lowercase(label) === 'angular',
            'b-l-primary': angular.lowercase(label) === 'bootstrap',
            'b-l-warning': angular.lowercase(label) === 'client',
            'b-l-success': angular.lowercase(label) === 'work'      
          };
        };
      }
            
      ListCtrl.$inject = ['$scope', 'inboxStorage', '$stateParams', '$http'];
      function ListCtrl($scope, inboxStorage, $stateParams, $http) {
        var vm = $scope;
        vm.fold = $stateParams.fold;
        vm.inboxes = inboxStorage.findAll();

        vm.populateData = populateData;
        // populate data
        if(vm.inboxes.length == 0){
          vm.populateData();
        }

        function populateData(){
          $http.get('apps/inbox/inbox.json').then(function (resp) {
            vm.inboxes = resp.data.inbox;
            vm.inboxes.forEach(function (item) {
                inboxStorage.create(item);
            });
          });
        }

      }

      DetailCtrl.$inject = ['$scope', 'inboxStorage', '$stateParams', '$state'];
      function DetailCtrl($scope, inboxStorage, $stateParams, $state) {
        var vm = $scope;
        vm.item = inboxStorage.find($stateParams);
        vm.labels = [
          {name: 'Angular', filter:'angular', color:'#23b7e5'},
          {name: 'Bootstrap', filter:'bootstrap', color:'#7266ba'},
          {name: 'Client', filter:'client', color:'#fad733'},
          {name: 'Work', filter:'work', color:'#27c24c'}
        ];
        vm.removeItem = removeItem;
        vm.updateItem = updateItem;
        
        function removeItem(item){
          inboxStorage.destroy(item);
          $state.go('app.inbox.list');
        }
        function updateItem(item, label){
          item.label = label;
          inboxStorage.update(item);
        }
      }

      function NewCtrl($scope) {
        var vm = $scope;
        vm.inbox = {
          to: {},
          subject: '',
          content: ''
        }
        vm.people = [
          { name: 'Adam',      email: 'adam@email.com',      age: 12, country: 'United States' },
          { name: 'Amalie',    email: 'amalie@email.com',    age: 12, country: 'Argentina' },
          { name: 'Estefanía', email: 'estefania@email.com', age: 21, country: 'Argentina' },
          { name: 'Adrian',    email: 'adrian@email.com',    age: 21, country: 'Ecuador' },
          { name: 'Wladimir',  email: 'wladimir@email.com',  age: 30, country: 'Ecuador' },
          { name: 'Samantha',  email: 'samantha@email.com',  age: 30, country: 'United States' },
          { name: 'Nicole',    email: 'nicole@email.com',    age: 43, country: 'Colombia' },
          { name: 'Natasha',   email: 'natasha@email.com',   age: 54, country: 'Ecuador' },
          { name: 'Michael',   email: 'michael@email.com',   age: 15, country: 'Colombia' },
          { name: 'Nicolás',   email: 'nicolas@email.com',    age: 43, country: 'Colombia' }
        ];
      }

      function LabelColor(){
        return function(scope, $el, attrs){
          $el.css({'color': attrs.color});
        }
      };

})();
