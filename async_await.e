namespace async_await
include std\task.e
include std\types.e as t
with trace


--**
-- 0(FALSE) = Quando o método main retornar, se houver task ainda, o app vai continuar executando.
-- 1(TRUE)  = Quando o método main retornar a aplicação encerra, embora tenha alguma task em execução ainda.
--
global integer CONF_NO_CLOSE_WHEN_MAIN_RETURNED = 1

--**
-- 1. Pode receber um id do routine_id();
-- 2. Pode receber um sequence, com {id_task, status} 
--      status = run | complete
--
public type Task(object TaskOrId)
    if integer(TaskOrId) or sequence(TaskOrId) then
        return TRUE
    else
        return FALSE
    end if
end type

sequence task_ids = {}
integer count_new_tasks = 0

--**
-- Executa uma função e espera por seu retorno assícronamente.
--
-- Parameters:
--		# ##routineId## : Um átomo com o runtime_id da função async.
--		# ##args##      : Argumentos da função.
--
-- Comments:
--
-- A task é criada de task_func, que chama o método real.
--
public function await(Task TaskOrId, sequence args = {})
    integer
        routineIdTaskf = 0,
        pos = 0
    atom task = 0
    
    if sequence(TaskOrId) then
        task = TaskOrId[1]
        
        for i = 1 to length(task_ids) do
            if task_ids[i][1] = task then
                pos = i
                break
            end if
            task_yield()
        end for
        
    else
        routineIdTaskf = routine_id("Task_func")
        task = task_create(routineIdTaskf, {TaskOrId, args})
        task_schedule(task, {0.1, 2})
        
        pos = length(task_ids)+1
        task_ids &= {{task, "run"}}
        count_new_tasks += 1
        
    end if

    while not equal(task_ids[pos][2], "complete") do
        task_delay(0.03)
    end while

    if length(task_ids[pos]) = 3 then
        return task_ids[pos][3]
    else
        return {}
    end if
end function

--**
-- Executa o equivalente a getc(fn)
--
-- Parameters:
--		# ##fn## : Um inteiro do id.
--
-- Comments:
--
-- Caso "fn" > 0 irá chamar getc(fn), caso contrário get_key() até char = {10, 13}.
--
public function await_getc(integer fn)
    integer char = 0
    integer result_char = 0
    if fn = 0 then
        while TRUE do
            char = get_key()
            
            if find(char, {10, 13}) then
                exit
                
            elsif char != -1 then
                result_char = char
                
            end if
            
            task_yield()
            
        end while
        
        puts(1, result_char)
        
    else
        result_char = getc(fn)
        
    end if
    
    return result_char
end function

--**
-- Executa o equivalente a gets(fn)
--
-- Parameters:
--		# ##fn## : Um inteiro do id.
--
-- Comments:
--
-- Caso "fn" > 0 irá chamar gets(fn), caso contrário get_key() em sequência até char = {10, 13}.
--
public function await_gets(integer fn)
    integer char = 0
    sequence str = ""
    
    if fn = 0 then
        while TRUE do
            char = get_key()
            
            if find(char, {10, 13}) then
                exit
                
            elsif char != -1 and char > 0 then
                str &= char
                puts(1, str)
                
            end if
            
            task_yield()
            
        end while
        
    else
        str = gets(fn)
        
    end if
    
    return str
    
end function

--**
-- Executa uma função de forma assíncrona e retorna o id da task.
--
-- Parameters:
--		# ##routineId## : Um átomo com o runtime_id da função async.
--		# ##args##      : Argumentos da função.
--
-- Comments:
--
-- A task é criada de task_func, que chama o método real.
--
public function async(integer routineIdRealMethod, sequence args = {})
    integer routineIdTaskf = routine_id("Task_func")
    atom task = task_create(routineIdTaskf, {routineIdRealMethod, args})
    task_schedule(task, {0.01, 6})
    
    task_ids &= {{task, "run"}}
    count_new_tasks += 1
    
    Task t = { task, routineIdRealMethod }
    
    return t
    
end function

--**
-- Executa um procedimento de forma assíncona e retorna o id da task.
--
-- Parameters:
--		# ##routineId## : Um átomo com o runtime_id do procedimento async.
--		# ##args##      : Argumentos do procedimento.
--
-- Comments:
--
-- A task é criada de task_proc, que chama o método real.
--
public function async_proc(integer routineIdRealMethod, sequence args = {})
    integer routineIdTaskp = routine_id("Task_proc")
    atom task = task_create(routineIdTaskp, {routineIdRealMethod, args})
    task_schedule(task, {0.01, 6})
    
    task_ids &= {{task, "run"}}
    count_new_tasks += 1
    
    Task t = { task, routineIdRealMethod }
    
    return t
    
end function

--**
-- Precedimento que incia o procedimento de forma assincrona.
--
-- Parameters:
--		# ##routineId## : Um átomo com o runtime_id do procedimento async.
--		# ##args##      : Argumentos do procedimento.
--
-- Comments:
--
-- Irá realizar uma call_proc(routinId).
--
procedure Task_proc(atom routineId, sequence args)
    call_proc(routineId, args)
    
    count_new_tasks -= 1
end procedure

--**
-- Precedimento que incia a função de forma assincrona e pega o retorno da chamada.
--
-- Parameters:
--		# ##routineId## : Um átomo com o runtime_id da função async.
--		# ##args##      : Argumentos da função.
--
-- Comments:
--
-- Irá realizar uma call_func(routineId)
--
procedure Task_func(atom routineId, sequence args)
    object result = call_func(routineId, args)
    
    for i = 1 to length(task_ids) do
        if equal(task_ids[i][1], task_self())  then
            task_ids[i] &= { result }
            task_ids[i][2] = "complete"
            break
        end if
        task_yield()
    end for
    
    count_new_tasks -= 1
    
end procedure

--**
-- Verifica se tem alguma tarefa em execução.
--
function contain_in_run()
    for i = 1 to length(task_ids) do
        if equal(task_ids[i][2], "run") then
            return TRUE
        end if
        task_yield()
    end for
    
    return FALSE
end function

--**
-- Inicializa uma procedure e mantém o controle do fluxo final do app.
--
-- Parameters:
--		# ##IdMethodMain## : Um átomo com o runtime_id do método main da aplicação.
--
public procedure init(atom IdMethodMain)
    task_schedule(task_self(), {0.01, 6})
    atom task_id_main = task_create(IdMethodMain, {})
    task_schedule(task_id_main, {0.01, 6})
    
    integer count = 0
    
    integer task_main_status = 1
    while 1 do
        task_delay(0.1)
        
        task_main_status = task_status(task_id_main)
        if (task_main_status = -1 and CONF_NO_CLOSE_WHEN_MAIN_RETURNED) or count_new_tasks = 0 then
            return
        end if
    end while
    
end procedure
