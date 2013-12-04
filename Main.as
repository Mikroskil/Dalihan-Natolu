package 
{
	import flash.display.Sprite;
	import flash.media.Microphone;
	import flash.system.Security;
	import org.bytearray.micrecorder.*;
	import org.bytearray.micrecorder.events.RecordingEvent;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.ActivityEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import flash.net.FileReference;

	public class Main extends Sprite
	{
		private var mic:Microphone;
		private var waveEncoder:WaveEncoder = new WaveEncoder();
		private var recorder:MicRecorder = new MicRecorder(waveEncoder);
		private var recBar:RecBar = new RecBar();
		private var tween:Tween;
		private var fileReference:FileReference = new FileReference();

		public function Main():void
		{
			recButton.stop();
			activity.stop();

			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);
			mic.gain = 100;
			mic.setLoopBack(true);
			mic.setUseEchoSuppression(true);
			Security.showSettings("2");

			addListeners();
		}

		private function addListeners():void
		{
			recButton.addEventListener(MouseEvent.MOUSE_UP, startRecording);
			recorder.addEventListener(RecordingEvent.RECORDING, recording);
			recorder.addEventListener(Event.COMPLETE, recordComplete);
			activity.addEventListener(Event.ENTER_FRAME, updateMeter);
		}

		private function startRecording(e:MouseEvent):void
		{
			if (mic != null)
			{
				recorder.record();
				e.target.gotoAndStop(2);

				recButton.removeEventListener(MouseEvent.MOUSE_UP, startRecording);
				recButton.addEventListener(MouseEvent.MOUSE_UP, stopRecording);

				addChild(recBar);

				tween = new Tween(recBar,"y",Strong.easeOut, -  recBar.height,0,1,true);
			}
		}

		private function stopRecording(e:MouseEvent):void
		{
			recorder.stop();

			mic.setLoopBack(false);
			e.target.gotoAndStop(1);

			recButton.removeEventListener(MouseEvent.MOUSE_UP, stopRecording);
			recButton.addEventListener(MouseEvent.MOUSE_UP, startRecording);

			tween = new Tween(recBar,"y",Strong.easeOut,0, - recBar.height,1,true);
		}

		private function updateMeter(e:Event):void
		{
			activity.gotoAndPlay(100 - mic.activityLevel);
		}

		private function recording(e:RecordingEvent):void
		{
			var currentTime:int = Math.floor(e.time / 1000);

			recBar.counter.text = String(currentTime);

			if (String(currentTime).length == 1)
			{
				recBar.counter.text = "00:0" + currentTime;
			}
			else if (String(currentTime).length == 2)
			{
				recBar.counter.text = "00:" + currentTime;
			}
		}

		private function recordComplete(e:Event):void
		{
			fileReference.save(recorder.output, "recording.mp3");
		}
	}
}