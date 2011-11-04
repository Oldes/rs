package {
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.Timer;

	public class TestRunner extends Sprite
	{
		public var output:TextField;
		public var page:Sprite;
		public var timer:Timer;
		public var testArray:Array;
				
		public function TestRunner()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			page = new Sprite();
			addChild( page )
			output = new TextField();
			output.selectable = false;
			output.x=10
			output.y=10
			output.width = this.stage.stageWidth-20;
			output.height = this.stage.stageHeight - 20;
			output.border = false;
			output.borderColor = 0xCCCCCC;
			page.addChild(output)
			logger('FLASH PLAYER 9 AS3/AVM2 PERFORMANCE TEST RUNNER');
			logger('URL:\thttp://www.onflex.org/perf/');
			logger('');	
			logger( new Date().toDateString().toUpperCase() + '  ' + new Date().toLocaleTimeString().toUpperCase() );
			logger('');			
			logger('   PLAYER VERSION\t' + Capabilities.version.toUpperCase());
			logger('   PLAYER VM VERSION\t' + System.vmVersion.toUpperCase());
			logger('   OPERATING SYSTEM\t' + Capabilities.os.toUpperCase());
			logger('');			
			addChild( output );			
			timer = new Timer( 0 );
			timer.addEventListener( TimerEvent.TIMER, executeTests );
			timer.start();
		}
		
		public function logger( out:String ):void
		{			
			output.appendText( out + '\n');		
		}
		
		public function executeTests( event:TimerEvent ):void
		{			
			if( ! testArray ){
				testArray = new Array();
				testArray.push(testsStart);
				testArray.push(test1);
				testArray.push(test2);
				testArray.push(test3);
				testArray.push(test4);
				testArray.push(test5);
				testArray.push(test6);
				testArray.push(test7);
				testArray.push(test8);
				testArray.push(test9);
				testArray.push(test10);
				testArray.push(test11);
				testArray.push(test12);
				testArray.push(testsComplete);			
			}			
			if( testArray.length > 0 ){
				testArray.shift()();
			}else{
				timer.stop();
			}	
		}
		
		public function testsStart():void
		{
			logger( '' )
			logger( '> PLAYER MEMORY:\t' + System.totalMemory*0.0009765625 +' Kb' );
			logger( '> PLAYER CLOCK:\t\t' + getTimer() );
			logger( '> TESTS STARTED');
			logger( '' );		
		}
		
		public function testsComplete():void
		{		
			logger( '' )
			logger( '> PLAYER MEMORY:\t' + System.totalMemory*0.0009765625 +' Kb' );
			logger( '> PLAYER CLOCK:\t\t' + getTimer() );						
			System.setClipboard( output.text );
			logger( '' );
			logger( 'REPORT TEXT COPIED TO CLIPBOARD' );		
		}		
		
		//////////////////////////////////
		//TESTS
		//////////////////////////////////
		
		private function test1():void
		{
			//vars				
			var a:Array;
			var i:int;
			var s:String;
			var after:int;
			var before:int;	
			var result:int;	
			
			a = new Array();
			for( i=0 ; i<1000; i++ ){
				a[i] = i + 'a';
			}
			
			s= "";
			before = getTimer();
			for ( i=0 ; i<500 ; i++ ){
				s = a.join( '-' );
			}
			after = getTimer();
			result = int(after-before)
			
			logger( '\t\tTEST 1: ' + result + ' ms' );
		}
		
		private function test2():void
		{
			//vars				
			var a:Array;
			var i:int;
			var j:int;
			var before:int;
			var after:int;
			var result:int;
			
			a = new Array(); 
			for( i=0 ; i<1000 ; i++ ){
				a[i] = i*33 + 'a';
			} 
			before = getTimer();
			for( i=0 ; i<500 ; i++ ){
				a.sort(); 
			}
			after = getTimer();
			result = int(after-before);	
			
			logger( '\t\tTEST 2: ' + result + ' ms' );
		}
		
		private function test3():void
		{
			//vars				
			var before:int;
			var after:int;
			var i:int;
			var t1:int;
			var t2:int;
			var s:String;
			var result:int;
			
			before = getTimer();			
			for( i=0 ; i<50000 ; i++ ){				
				s = "012"+"abc"+"def"+"345"+i+"012"+"abc"+"def"+"345"+"012"+"abc"+"def"+"345";
			}
			after = getTimer();			
			t1 = int( after-before );			
			s = "";
			before = getTimer();			
			for( i=0 ; i<50000 ; i++ ) {				
				s = "a"+i+"g";			
			}			
			after = getTimer();			
			t2 = int(after-before);						
			result = int( t1-t2 );
			
			logger( '\t\tTEST 3: ' + result + ' ms' );
		}
		
		private function test4():void
		{
			//vars				
			var before:int;
			var after:int;
			var s:String = '';
			var i:int;
			var t1:int;
			var t2:int;	
			var result:int;	
			
			before = getTimer();
			for( i=0 ; i<50000 ; i++ ){
				s = "The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+ "The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+ i + "The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated"+"The only thing that sustains one through life is the consciousness of the immense inferiority of everybody else, and this is a feeling that I have always cultivated";
			}
			after = getTimer();
			t1 = int(after-before);
			s = "";
			before = getTimer();
			for( i=0 ; i<50000 ; i++){
				s = "a"+i+"g";
			}
			after = getTimer();
			t2 = (after-before);
			result = int(t1-t2);	
			
			logger( '\t\tTEST 4: ' + result + ' ms' );
		}
		
		private function test5():void
		{		
			//vars				
			var before:int;
			var after:int;
			var series:Number = 0;
			var limit:Number = 12;
			var counter:Number = 1;
			var result:int;
			
			before = getTimer();  
			while( series < limit ){ 
				series += 1 / counter;
				counter++;
			}
			after = getTimer();
			result = int( after - before );
		
			logger( '\t\tTEST 5: ' + result + ' ms' );
		}
		
		private function test6():void
		{
			//vars				
			var before:int;
			var after:int;
			var a:String='';
			var i:int;
			var result:int;
			
   			for( i=0 ; i<100 ; i++ ) {
      			a += 'abcdefghij';
   			}
			before = getTimer();
			for( i=0 ; i<10000 ; i++ ) {
    			a.substring( 234 , 567 );
			}
			after = getTimer();
			result = int( after - before );
			
			logger( '\t\tTEST 6: ' + result + ' ms' );
		}
		
		private function test7():void
		{
			//vars				
			var before:int;
			var after:int;
			var a:String = '';
			var i:int;
			var result:int;
			
			for( i=0 ; i<100 ; i++ ){
				a += 'abcdefghij';
			}
			a+='k';
			before = getTimer();
			for( i=0 ; i<40000 ; i++ ){
				a.indexOf( 'k' );
			}
			after = getTimer();
			result = int( after - before );
			
			logger( '\t\tTEST 7: ' + result + ' ms' );
		}
		
		private function test8():void
		{			
			//vars				
			var before:int;
			var after:int;
			var i:int;
			var n:Number = 500;
			var result:int;
			
			before = getTimer();
			for( i=0 ; i<40000 ; i++ ){
				Math.round( Math.random() * n )
			}
			after = getTimer();
			result = int( after - before );
			
			logger( '\t\tTEST 8: ' + result + ' ms' );
		}
		
		private function test9():void
		{
			//vars				
			var after:int;
			var before:int;
			var i:int;
			var result:int;
			
			before = getTimer();
			for( i=0 ; i<10000000 ; i++ ) {}
			after = getTimer();
			result = int( after - before );
			
			logger( '\t\tTEST 9: ' + result + ' ms' );
		}
		
		
		private function test10():void
		{
			//vars				
			var before:int;
			var after:int;
			var colors:Array = new Array("red","blue","green","orange","purple","yellow","brown","black","white","gray");
			var i:int;
			var j:int;
			var temp:int;
			var colorLength:int;
			var fav:String;
			var favArray:Array;
			var favArrayLength:int;
			var name:String;
			var email:String;
			var result:int;
						
			before = getTimer();
			colors = new Array("red","blue","green","orange","purple","yellow","brown","black","white","gray");
			endResult = "";
			for( i=0 ; i<5000 ; i++ ){
				temp = int( Math.round( i * Math.SQRT1_2 ) );
				addResult( temp.toString() );
			}
			colorLength = int( colors.length );
			for( i=0 ; i<colorLength ; i++ ){
				fav = "My favorite color is " + colors[i] + ".\n";
				addResult( fav );
				favArray = fav.split(" ");
				favArrayLength = int(favArray.length);
				for( j=0 ; j<favArrayLength; j++ ){
					addResult( favArray[j] );
				}
			}
			for( i=0 ; i<5000 ; i++ ){
				name = makeName( 8 );
				email = name + "@mac.com";
				addResult( email );
			}
			after = getTimer();		
			result = int( after - before );
			
			logger( '\t\tTEST 10: ' + result + ' ms' );
		}
		
		private var endResult:String = "";

		private function addResult( r:String ):void {
			endResult += "\n" + r ;
		}
		
		private var letters:Array = new Array("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");

		private function makeName( n:int ):String {
			
			//vars				
			var tmp:String = "";
			var i:int;
			var l:Number;
			
			for( i=0 ; i<n ; i++ ){
				l = int( Math.floor( 26 * Math.random() ) );
				tmp += letters[l];
			}
			return tmp;
		}
			
		private function test11():void
		{
			//vars				
			var before:int
			var after:int
			var s:String;
			var i:int;
			var md:MD5;
			var result:int
			
			before = getTimer();
			s='';
    		md = new MD5();
			for( i=0 ; i<1000 ; i++ ){
				s = md.str_md5( 'HTML' );
			}			
			after = getTimer();		
			result = int( after - before );
			
			logger( '\t\tTEST 11: ' + result + ' ms' );
		}
		
		private function test12():void 
		{
			//vars				
			var before:int;
			var i:int;
			var after:int;
			var result:int;
			
			before = getTimer();
			for( i=0 ; i<80000 ; i++ ){
				test12sub( i );
			}
			after = getTimer();		
			result = int( after - before );
			
			logger( '\t\tTEST 12: ' + result + ' ms' );
		}
		
		private function test12sub( i:int ):Number
		{
			return 5 * i + 2 + i ;
		}				
						
	}
	
}
