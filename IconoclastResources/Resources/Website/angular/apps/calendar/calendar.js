(function() {
    'use strict';
    angular
        .module('app')
        .controller('FullcalendarCtrl', FullcalendarCtrl);

        function FullcalendarCtrl($scope) {
          var vm = $scope;
          var date = new Date();
          var d = date.getDate();
          var m = date.getMonth();
          var y = date.getFullYear();

          /* event source that pulls from google.com */
          vm.eventSource = {
                  url: "http://www.google.com/calendar/feeds/usa__en%40holiday.calendar.google.com/public/basic",
                  className: 'gcal-event',           // an option!
                  currentTimezone: 'America/Chicago' // an option!
          };

          /* event source that contains custom events on the scope */
          vm.events = [
            {title:'All Day Event', start: new Date(y, m, 1), className: ['white'], location:'New York', info:'This a all day event that will start from 9:00 am to 9:00 pm, have fun!'},
            {title:'Dance class', start: new Date(y, m, 3), end: new Date(y, m, 4, 9, 30), allDay: false, className: ['danger'], location:'London', info:'Two days dance training class.'},
            {title:'Game racing', start: new Date(y, m, 6, 16, 0), className: ['white'], location:'Hongkong', info:'The most big racing of this year.'},
            {title:'Soccer', start: new Date(y, m, 8, 15, 0), className: ['info'], location:'Rio', info:'Do not forget to watch.'},
            {title:'Family', start: new Date(y, m, 9, 19, 30), end: new Date(y, m, 9, 20, 30), className: ['white'], info:'Family party'},
            {title:'Long Event', start: new Date(y, m, d - 5), end: new Date(y, m, d - 2), className: ['success'], location:'HD City', info:'It is a long long event'},
            {title:'Play game', start: new Date(y, m, d - 1, 16, 0), className: ['white'], location:'Tokyo', info:'Tokyo Game Racing'},
            {title:'Birthday Party', start: new Date(y, m, d + 1, 19, 0), end: new Date(y, m, d + 1, 22, 30), allDay: false, className: ['white'], location:'New York', info:'Party all day'},
            {title:'Repeating Event', start: new Date(y, m, d + 4, 16, 0), alDay: false, className: ['white'], location:'Home Town', info:'Repeat every day'},      
            {title:'Click for Google', start: new Date(y, m, 28), end: new Date(y, m, 29), url: 'http://google.com/', className: ['white']},
            {title:'Feed cat', start: new Date(y, m+1, 6, 18, 0), className: ['success']}
          ];

          /* alert on dayClick */
          vm.precision = 400;
          vm.lastClickTime = 0;
          vm.alertOnEventClick = function( date, jsEvent, view ){
            var time = new Date().getTime();
            if(time - vm.lastClickTime <= vm.precision){
                vm.events.push({
                  title: 'New Event',
                  start: date,
                  className: ['white b-l-2x b-l-info']
                });
            }
            vm.lastClickTime = time;
          };
          /* alert on Drop */
          vm.alertOnDrop = function(event, delta, revertFunc, jsEvent, ui, view){
             vm.alertMessage = ('Event Droped to make dayDelta ' + delta);
          };
          /* alert on Resize */
          vm.alertOnResize = function(event, delta, revertFunc, jsEvent, ui, view){
             vm.alertMessage = ('Event Resized to make dayDelta ' + delta);
          };

          vm.overlay = $('.fc-overlay');
          vm.alertOnMouseOver = function( event, jsEvent, view ){
            vm.event = event;
            vm.overlay.removeClass('left right top').find('.arrow').removeClass('left right top pull-up');
            var wrap = $(jsEvent.target).closest('.fc-event');
            var cal = wrap.closest('.calendar');
            var left = wrap.offset().left - cal.offset().left;
            var right = cal.width() - (wrap.offset().left - cal.offset().left + wrap.width());
            var top = cal.height() - (wrap.offset().top - cal.offset().top + wrap.height());
            if( right > vm.overlay.width() ) { 
              vm.overlay.addClass('left').find('.arrow').addClass('left pull-up')
            }else if ( left > vm.overlay.width() ) {
              vm.overlay.addClass('right').find('.arrow').addClass('right pull-up');
            }else{
              vm.overlay.find('.arrow').addClass('top');
            }
            if( top < vm.overlay.height() ) { 
              vm.overlay.addClass('top').find('.arrow').removeClass('pull-up').addClass('pull-down')
            }
            (wrap.find('.fc-overlay').length == 0) && wrap.append( vm.overlay );
          }

          /* config object */
          vm.uiConfig = {
            calendar:{
              height: 450,
              editable: true,
              header:{
                left: 'prev',
                center: 'title',
                right: 'next'
              },
              dayClick: vm.alertOnEventClick,
              eventDrop: vm.alertOnDrop,
              eventResize: vm.alertOnResize,
              eventMouseover: vm.alertOnMouseOver
            }
          };
          
          /* add custom event*/
          vm.addEvent = function() {
            vm.events.push({
              title: 'New Event',
              start: new Date(y, m, d),
              className: ['white b-l-info b-l-2x']
            });
            console.log(vm.events);
          };

          /* remove event */
          vm.remove = function(index) {
            vm.events.splice(index,1);
          };

          /* Change View */
          vm.changeView = function(view, calendar) {
            $('.calendar').fullCalendar('changeView', view);
          };

          vm.today = function(calendar) {
            $('.calendar').fullCalendar('today');
          };

          /* event sources array*/
          vm.eventSources = [vm.events];
        }
})();
