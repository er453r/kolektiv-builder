package dev.kolektiv.builder

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class UtilsController {
    @GetMapping("check")
    fun healthCheck() = "OK"
}
