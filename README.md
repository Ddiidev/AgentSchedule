
# Agent scheduler

Adiciona um camada de tempo de execução para gerenciar o scheduler de tasks.



## Uso/Exemplos

```Euphoria
import assync_await.e

procedure main()

    sequence value = await( routine_id("get_name"), { "André" } )
    
    puts(1, value)
    -- André
    
end procedure

function get_name(sequence name)
    task_delay(1) -- Espera assícronamente por 1seg.
    return name
end function

init( routine_id("main") )
```

Visto que o método precisa ter chamadas task_yield() / task_delay([ms])
para que nã tenha métodos bloqueantes.

## Stack utilizada

A linguagem se chama [Euphoria](https://openeuphoria.org), linguagem procedural, mas como algumas ideias diferentes.
Achei legal implementar um agent scheduler, até porque seria relativamente simples o desenvolvimento.
