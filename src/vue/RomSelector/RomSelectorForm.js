export default {
  data:{
    romList:[],
    ipAddress: null,
    selectedRom: null
  },
  mounted(){
    // TODO: for now
    this.romList = [{
      name: "Guilty Gear",
      location: "AtomisWave/AW-GuiltyGearIsuka.bin"
    }]
  },
  methods:{
    onSelected(){
      // TODO: On Selected
    }
  }
}