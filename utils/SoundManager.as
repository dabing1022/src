package utils{
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.utils.Dictionary;

    public class SoundManager{
        private var soundArr:Dictionary;
        private var soundChannelsArr:Array;
        /**soundMute:是否已经静音*/
        public var soundMute:Boolean = false;
        /**soundTrackChannel:用来存储某时刻的唯一声道*/
        private var soundTrackChannel:SoundChannel = new SoundChannel();
        private var tempSound:Sound;
        private var tempSoundTransform:SoundTransform = new SoundTransform();
        private var muteSoundTransform:SoundTransform = new SoundTransform();
        private static var instance:SoundManager;
        public function SoundManager():void{
            soundArr = new Dictionary();
            soundChannelsArr = new Array();

            init();
        }

        public static function getInstance():SoundManager{
            if(instance == null){
                instance = new SoundManager();
            }
            return instance;
        }

		//SEX 0女1男
        private function init():void{
			addSound(Resource.SND_CHOOSE_CARD, ResourceUtils.getSound(Resource.SND_CHOOSE_CARD));
			addSound(Resource.SND_INTO_TABLE, ResourceUtils.getSound(Resource.SND_INTO_TABLE));
			addSound(Resource.SND_SEND_CARDS, ResourceUtils.getSound(Resource.SND_SEND_CARDS));
			addSound(Resource.SND_RESULT_NO_NIU, ResourceUtils.getSound(Resource.SND_RESULT_NO_NIU));
			addSound(Resource.SND_RESULT_YOU_NIU, ResourceUtils.getSound(Resource.SND_RESULT_YOU_NIU));
			addSound("male-1", ResourceUtils.getSound(Resource.SND_NO_NIU_MALE));
			addSound("female-1", ResourceUtils.getSound(Resource.SND_NO_NIU_FEMALE));
			addSound("male1", ResourceUtils.getSound(Resource.SND_NIU_YI_MALE));
			addSound("female1", ResourceUtils.getSound(Resource.SND_NIU_YI_FEMALE));
			addSound("male2", ResourceUtils.getSound(Resource.SND_NIU_ER_MALE));
			addSound("female2", ResourceUtils.getSound(Resource.SND_NIU_ER_FEMALE));
			addSound("male3", ResourceUtils.getSound(Resource.SND_NIU_SAN_MALE));
			addSound("female3", ResourceUtils.getSound(Resource.SND_NIU_SAN_FEMALE));
			addSound("male4", ResourceUtils.getSound(Resource.SND_NIU_SI_MALE));
			addSound("female4", ResourceUtils.getSound(Resource.SND_NIU_SI_FEMALE));
			addSound("male5", ResourceUtils.getSound(Resource.SND_NIU_WU_MALE));
			addSound("female5", ResourceUtils.getSound(Resource.SND_NIU_WU_FEMALE));
			addSound("male6", ResourceUtils.getSound(Resource.SND_NIU_LIU_MALE));
			addSound("female6", ResourceUtils.getSound(Resource.SND_NIU_LIU_FEMALE));
			addSound("male7", ResourceUtils.getSound(Resource.SND_NIU_QI_MALE));
			addSound("female7", ResourceUtils.getSound(Resource.SND_NIU_QI_FEMALE));
			addSound("male8", ResourceUtils.getSound(Resource.SND_NIU_BA_MALE));
			addSound("female8", ResourceUtils.getSound(Resource.SND_NIU_BA_FEMALE));
			addSound("male9", ResourceUtils.getSound(Resource.SND_NIU_JIU_MALE));
			addSound("female9", ResourceUtils.getSound(Resource.SND_NIU_JIU_FEMALE));
			addSound("male0", ResourceUtils.getSound(Resource.SND_NIU_NIU_MALE));
			addSound("female0", ResourceUtils.getSound(Resource.SND_NIU_NIU_FEMALE));
			addSound(Resource.SND_WU_HUA_NIU_MALE, ResourceUtils.getSound(Resource.SND_WU_HUA_NIU_MALE));
			addSound(Resource.SND_WU_HUA_NIU_FEMALE, ResourceUtils.getSound(Resource.SND_WU_HUA_NIU_FEMALE));
			addSound(Resource.SND_BET_COIN, ResourceUtils.getSound(Resource.SND_BET_COIN));
			addSound(Resource.SND_BOMB, ResourceUtils.getSound(Resource.SND_BOMB));
			addSound(Resource.SND_GET_READY, ResourceUtils.getSound(Resource.SND_GET_READY));
        }

        /**
         *@param soundName  声音名字
         *@param sound      声音
         */
        private function addSound(soundName:String, sound:Sound):void{
            soundArr[soundName] = sound;           
        }

        /**
         *@param      soundName          声音名字
         *@param      isSoundTrack       声音是否为声道,当为声道时和其他声音区别对待。
         *@param      loops              循环次数
         *@param      offset             应开始回放的初始位置（以毫秒为单位）
         *@param      volume             音量
         * 一次播放一个声道
         */
        public function playSound(soundName:String,isSoundTrack:Boolean,loops:int = 1,offset:Number = 0,volume:Number = 1):void{
            tempSound = soundArr[soundName];
            tempSoundTransform.volume = volume;
            if(isSoundTrack){
                if(soundTrackChannel != null){
                    soundTrackChannel.stop();
                }
                soundTrackChannel = tempSound.play(offset,loops);
                soundTrackChannel.soundTransform = tempSoundTransform;
            }else{
                //非声道声音
                soundChannelsArr[soundName] = tempSound.play(offset,loops);
                soundChannelsArr[soundName].soundTransform = tempSoundTransform;
            }
        }

        public function stopSound(soundName:String,isSoundTrack:Boolean):void{
            if(isSoundTrack){
                soundTrackChannel.stop();
            }else{
                soundChannelsArr[soundName].stop();
            }
        }

        public function muteSound():void{
            if(soundMute){
                soundMute = false;
                muteSoundTransform.volume = 1;
                SoundMixer.soundTransform = muteSoundTransform;
            }else{
                soundMute = true;
                muteSoundTransform.volume = 0;
                SoundMixer.soundTransform = muteSoundTransform;
            }
        }
    }
}
