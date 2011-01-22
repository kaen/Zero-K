unitDef = {
  unitname            = [[corvalk]],
  name                = [[Valkyrie]],
  description         = [[Air Transport]],
  acceleration        = 0.09,
  amphibious          = true,
  bankscale           = [[1]],
  bmcode              = [[1]],
  brakeRate           = 7.5,
  buildCostEnergy     = 80,
  buildCostMetal      = 80,
  builder             = false,
  buildPic            = [[CORVALK.png]],
  buildTime           = 80,
  canDropFlare        = false,
  canFly              = true,
  canGuard            = true,
  canload             = [[1]],
  canMove             = true,
  canPatrol           = true,
  canstop             = [[1]],
  canSubmerge         = false,
  category            = [[GUNSHIP UNARMED]],
  collide             = false,
  corpse              = [[DEAD]],
  cruiseAlt           = 80,

  customParams        = {
    description_bp = [[Transporte aéreo]],
    description_fr = [[Transport Aerien]],
    helptext       = [[The Valkyrie the basic air transport. It's used to ferry units to the front or make a drop deep behind enemy lines, but should not be used to land in areas with any kind of AA cover.]],
    helptext_bp    = [[A unidade de transporte básica de Logos. é usada para levar unidades rapidamente de um lugar a outro ou para depositalas dentro do território inimigo, mas n?o deve ser usada para aterrisagens em qualquer lugar com defesas anti-aéreas decentes.]],
    helptext_fr    = [[Le Valkyrie est une unit? de transport a?rien basique. Elle peut ?tre utilis?e pour a?roporter des troups sur le front comme derri?re les lignes ennemies. Il faut cependant ?viter ? tout prix les endroits couvert par de l'Anti-Air: il n'y survivrait pas.]],
  },

  defaultmissiontype  = [[VTOL_standby]],
  explodeAs           = [[GUNSHIPEX]],
  floater             = true,
  footprintX          = 3,
  footprintZ          = 3,
  iconType            = [[airtransport]],
  idleAutoHeal        = 5,
  idleTime            = 1800,
  maneuverleashlength = [[1280]],
  mass                = 90,
  maxDamage           = 250,
  maxVelocity         = 15.1545,
  minCloakDistance    = 75,
  moverate1           = [[1]],
  moverate2           = [[2]],
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK]],
  objectName          = [[CORVALK.s3o]],
  pitchscale          = [[1]],
  releaseHeld         = true,
  seismicSignature    = 0,
  selfDestructAs      = [[GUNSHIPEX]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:ATLAS_ENGINE]],
    },

  },

  side                = [[CORE]],
  sightDistance       = 125,
  smoothAnim          = true,
  steeringmode        = [[1]],
  TEDClass            = [[VTOL]],
  transportCapacity   = 1,
  transportMass       = 650,
  transportSize       = 4,
  turnInPlace         = 0,
  turnRate            = 550,

  featureDefs         = {

    DEAD  = {
      description      = [[Wreckage - Valkyrie]],
      blocking         = true,
      category         = [[corpses]],
      damage           = 250,
      energy           = 0,
      featureDead      = [[DEAD2]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[40]],
      hitdensity       = [[100]],
      metal            = 32,
      object           = [[corvalk_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 32,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    DEAD2 = {
      description      = [[Debris - Valkyrie]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 250,
      energy           = 0,
      featureDead      = [[HEAP]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 32,
      object           = [[debris2x2c.s3o]],
      reclaimable      = true,
      reclaimTime      = 32,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP  = {
      description      = [[Debris - Valkyrie]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 250,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 16,
      object           = [[debris2x2c.s3o]],
      reclaimable      = true,
      reclaimTime      = 16,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ corvalk = unitDef })
